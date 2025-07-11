class posbookworm (
  Boolean $enabled = str2bool($facts['posbookworm']),
  $directory = '/etc/maadix/bookworm',
) {

  if $enabled {

    #define scripts
    $scripts = ['delete_obsolete_packages.sh',
                'update_docker.sh',
                'activate_groups.sh',
                'deactivate_groups.sh',
                'iptables_apache_accept.sh',
                'set_ready_api.sh',
                'send_posbookworm_report.sh',
                'send_posbookworm_notify.sh']
    $scripts.each |String $script| {
      file {"$directory/${script}":
        owner   => 'root',
        group   => 'root',
        mode    => '0700',
        content => template("posbookworm/${script}"),
      }
    }

    exec { 'reset posbookworm log':
      command   => "/bin/rm $directory/logs/posbookworm",
      onlyif    => "/usr/bin/test -f $directory/logs/posbookworm",
    } ->
    #we are in bookworm, set vm status in api to ready
    exec { 'set_ready_api 1':
      command   => "/bin/bash -c '$directory/set_ready_api.sh > $directory/logs/posbookworm 2>&1'",
      logoutput => true,
      timeout   => 300,
    } ->
    exec { 'system background wait 1':
      command   => "/bin/bash -c '/etc/maadix/scripts/system_background_wait.sh >> $directory/logs/posbookworm 2>&1'",
      logoutput => true,
      timeout   => 7200,
    } ->
    exec { 'system background stop 1':
      command   => "/bin/bash -c '/etc/maadix/scripts/system_background_stop.sh >> $directory/logs/posbookworm 2>&1'",
      logoutput => true,
      timeout   => 7200,
    } ->
    exec { 'iptables apache drop':
      command   => "/bin/bash -c '$directory/iptables_apache_drop.sh >> $directory/logs/posbookworm 2>&1'",
      logoutput => true,
    }

    #mark packages as manually installed to avoid autoremove to purge them later
    exec { 'mark slapd as manually installed':
      command => '/usr/bin/apt-mark manual slapd',
      logoutput => true,
    }


    #clean downloaded packages
    exec { 'clean apt':
      command => '/usr/bin/apt-get clean',
    }

    #clean unused images and containers
    /*
    if ($facts['docker_group']){
      exec { 'clean docker before apply bookworm catalog':
        command   => '/usr/bin/docker run --rm --userns host -v /var/run/docker.sock:/var/run/docker.sock -v /etc:/etc -e GRACE_PERIOD_SECONDS=1800 spotify/docker-gc',
        logoutput => true,
      }
    }
    */

    if ($facts['docker_group']){
      exec { 'update docker':
        command   => "/bin/bash -c '$directory/update_docker.sh >> $directory/logs/posbookworm 2>&1'",
        logoutput => true,
        timeout   => 3600,
      }
    }

    #reinstall gems for this OS
    if ($facts['mastodon_group']){
      exec { 'mastodon bundle force reinstall':
        command         => "bundle install --force -j${facts['processors']['count']}",
        cwd             => '/var/www/mastodon/mastodon',
        environment     => [ 'HOME=/var/www/mastodon' ],
        user            => 'mastodon',
        timeout         => 7200,
        path            => '/usr/bin:/bin:/var/www/mastodon/.rbenv/shims/',
        logoutput       => true,
      }
    }

    /*
    if ($facts['discourse_group']){
      exec { 'rebuild discourse app':
        command   => "/usr/bin/sudo /var/discourse/launcher rebuild app >> $directory/logs/posbookworm 2>&1",
        timeout   => 7200,
      }
    }
    */

    exec { 'run puppet to apply bookworm catalog':
      #run puppet to apply bookworm catalog without purging certs
      command   => "/usr/bin/choom -n -1000 -- /usr/local/bin/puppet agent --certname ${facts['networking']['hostname']}.maadix.org --test --skip_tags letsencrypt::certonly >> $directory/logs/posbookworm 2>&1",
      logoutput => true,
      # --test option implies --detailed-exitcodes. and Exitcode of 2 means that The run succeeded, and some resources were changed
      returns   => 2,
      timeout   => 7200,
    }

    exec { 'iptables apache accept':
      command   => "/bin/bash -c '$directory/iptables_apache_accept.sh >> $directory/logs/posbookworm 2>&1'",
      logoutput => true,
      require   =>[
                  Exec['run puppet to apply bookworm catalog'],
                  ],
    } ->
    exec { 'system background wait 2':
      command   => "/bin/bash -c '/etc/maadix/scripts/system_background_wait.sh >> $directory/logs/posbookworm 2>&1'",
      logoutput => true,
      timeout   => 7200,
    } ->
    exec { 'system background stop 2':
      command   => "/bin/bash -c '/etc/maadix/scripts/system_background_stop.sh >> $directory/logs/posbookworm 2>&1'",
      logoutput => true,
      timeout   => 7200,
    } ->
    exec { 'activate all groups':
      command   => "/bin/bash -c '$directory/activate_groups.sh >> $directory/logs/posbookworm 2>&1'",
      logoutput => true,
    } ->
    exec { 'run puppet after groups reactivating':
      command   => "/usr/bin/choom -n -1000 -- /usr/local/bin/puppet agent --certname ${facts['networking']['hostname']}.maadix.org --test >> $directory/logs/posbookworm 2>&1",
      logoutput => true,
      # --test option implies --detailed-exitcodes. and Exitcode of 2 means that The run succeeded, and some resources were changed
      returns   => 2,
      timeout   => 7200,
    } ->
    exec { 'clean apt after groups reactivating':
      command => '/usr/bin/apt-get clean',
    } ->
    exec { 'system background wait 3':
      command   => "/bin/bash -c '/etc/maadix/scripts/system_background_wait.sh >> $directory/logs/posbookworm 2>&1'",
      logoutput => true,
      timeout   => 7200,
    } ->
    exec { 'system background stop 3':
      command   => "/bin/bash -c '/etc/maadix/scripts/system_background_stop.sh >> $directory/logs/posbookworm 2>&1'",
      logoutput => true,
      timeout   => 7200,
    } ->
    exec { 'deactivate deactivated groups':
      command   => "/bin/bash -c '$directory/deactivate_groups.sh >> $directory/logs/posbookworm 2>&1'",
      logoutput => true,
    } ->
    exec { 'run puppet after groups deactivating':
      command   => "/usr/bin/choom -n -1000 -- /usr/local/bin/puppet agent --certname ${facts['networking']['hostname']}.maadix.org --test >> $directory/logs/posbookworm 2>&1",
      logoutput => true,
      # --test option implies --detailed-exitcodes. and Exitcode of 2 means that The run succeeded, and some resources were changed
      returns   => 2,
      timeout   => 7200,
    } ->
    /*
    exec { 'delete_obsolete_packages.sh':
      command   => "/bin/bash -c '$directory/delete_obsolete_packages.sh >> $directory/logs/posbookworm 2>&1'",
      timeout   => 3600,
      logoutput => true,
    } ->
    */
    exec { 'system background wait 4':
      command   => "/bin/bash -c '/etc/maadix/scripts/system_background_wait.sh >> $directory/logs/posbookworm 2>&1'",
      logoutput => true,
      timeout   => 7200,
    } ->
    exec { 'system background stop 4':
      command   => "/bin/bash -c '/etc/maadix/scripts/system_background_stop.sh >> $directory/logs/posbookworm 2>&1'",
      logoutput => true,
      timeout   => 7200,
    } ->
    exec { 'run puppet after removing obsolete packages':
      command   => "/usr/bin/choom -n -1000 -- /usr/local/bin/puppet agent --certname ${facts['networking']['hostname']}.maadix.org --test >> $directory/logs/posbookworm 2>&1",
      logoutput => true,
      # --test option implies --detailed-exitcodes. and Exitcode of 2 means that The run succeeded, and some resources were changed
      returns   => 2,
      timeout   => 7200,
    } ->
    exec { 'set_ready_api 2':
      command   => "/bin/bash -c '$directory/set_ready_api.sh >> $directory/logs/posbookworm 2>&1'",
      logoutput => true,
      timeout   => 300,
    }->
    #remove maadixupgrade user and group
    user { 'maadixupgrade':
      ensure    => 'absent',
    }->
    group { 'maadixupgrade':
      ensure    => 'absent',
    }->
    #remove maadixupgrade home
    file {'/home/maadixupgrade':
      ensure    => absent,
      recurse   => true,
      purge     => true,
      force     => true,
    }->    
    #remove maadixupgrade sudo
    file { '/etc/sudoers.d/10_maadixupgrade':
      ensure    => 'absent',
    }


    #clean unused images and containers
    /*
    if ($facts['docker_group']){
      exec { 'clean docker after apply bookworm catalog':
        command   => '/usr/bin/docker run --rm --userns host -v /var/run/docker.sock:/var/run/docker.sock -v /etc:/etc -e GRACE_PERIOD_SECONDS=1800 spotify/docker-gc',
        logoutput => true,
      }
    }
    */

    exec { 'send cpanel to ready':
      command   => '/etc/init.d/setreadycpanel restart',
    }

    exec { 'disable and remove script posbookworm':
      command   => '/usr/sbin/update-rc.d posbookworm remove && /bin/rm /etc/init.d/posbookworm && /bin/rm -r /etc/systemd/system/posbookworm.service.d',
    }

    exec { 'delete persistent iptables rules':
      command   => '/bin/rm /etc/iptables/*',
      onlyif    => 'ls -l /etc/iptables/* | grep rules',
      path      => ['/usr/bin','/usr/sbin','/bin','/sbin'],
    }

    exec { 'system background start':
      command   => "/bin/bash -c '/etc/maadix/scripts/system_background_start.sh >> $directory/logs/posbookworm 2>&1'",
      logoutput => true,
      timeout   => 7200,
    }

    exec { 'send report':
      command   => "/bin/bash -c '$directory/send_posbookworm_report.sh'",
      timeout   => 300,
    }

    exec { 'send posbookworm notify':
      command   => "/bin/bash -c '$directory/send_posbookworm_notify.sh'",
      logoutput => true,
      timeout   => 300,
      require   =>[
                  Exec['set_ready_api 2'],
                  ],
    } ->
    exec { 'enable setreadycpanel':
      command   => '/bin/systemctl enable setreadycpanel',
    }


  }

}
