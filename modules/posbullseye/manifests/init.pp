class posbullseye (
  $enabled = str2bool("$::posbullseye"),
  $directory = '/etc/maadix/bullseye',
) {

  validate_bool($enabled)

  if $enabled {

    #define scripts
    $scripts = ['delete_obsolete_packages.sh',
                'upgrade_easyrsa_openvpn.sh',
                'update_docker.sh',
                'activate_groups.sh',
                'deactivate_groups.sh',
                'iptables_apache_accept.sh',
                'set_ready_api.sh',
                'send_posbullseye_report.sh',
                'send_posbullseye_notify.sh']
    $scripts.each |String $script| {
      file {"$directory/${script}":
        owner   => 'root',
        group   => 'root',
        mode    => '0700',
        content => template("posbullseye/${script}"),
      }
    }

    exec { 'reset posbullseye log':
      command   => "/bin/rm $directory/logs/posbullseye",
      onlyif    => "/usr/bin/test -f $directory/logs/posbullseye",
    } ->
    #we are in bullseye, set vm status in api to ready
    exec { 'set_ready_api 1':
      command   => "/bin/bash -c '$directory/set_ready_api.sh > $directory/logs/posbullseye 2>&1'",
      logoutput => true,
    } ->
    exec { 'system background wait 1':
      command   => "/bin/bash -c '/etc/maadix/scripts/system_background_wait.sh >> $directory/logs/posbullseye 2>&1'",
      logoutput => true,
      timeout   => 7200,
    } ->
    exec { 'system background stop 1':
      command   => "/bin/bash -c '/etc/maadix/scripts/system_background_stop.sh >> $directory/logs/posbullseye 2>&1'",
      logoutput => true,
      timeout   => 7200,
    } ->
    exec { 'iptables apache drop':
      command   => "/bin/bash -c '$directory/iptables_apache_drop.sh >> $directory/logs/posbullseye 2>&1'",
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
    if ($::docker_group){
      exec { 'clean docker before apply bullseye catalog':
        command   => '/usr/bin/docker run --rm --userns host -v /var/run/docker.sock:/var/run/docker.sock -v /etc:/etc -e GRACE_PERIOD_SECONDS=1800 spotify/docker-gc',
        logoutput => true,
      }
    }

    if ($::docker_group){
      exec { 'update docker':
        command   => "/bin/bash -c '$directory/update_docker.sh >> $directory/logs/posbullseye 2>&1'",
        logoutput => true,
        timeout   => 1800,
      }
    }

    if ($::discourse_group){
      exec { 'rebuild discourse app':
        command   => "/usr/bin/sudo /var/discourse/launcher rebuild app >> $directory/logs/posbullseye 2>&1",
        timeout   => 7200,
      }
    }

    #upgrade openvpn
    if ($::openvpn_group){
      exec { 'openvpn restore crl.pem':
        command   => "rm /etc/openvpn/$::fqdn/easy-rsa/keys/crl.pem && cp /etc/openvpn/$::fqdn/crl.pem /etc/openvpn/$::fqdn/easy-rsa/keys/crl.pem && chmod 600 /etc/openvpn/$::fqdn/easy-rsa/keys/crl.pem",
        logoutput => true,
        timeout   => 1800,
        path      => ['/usr/bin','/bin'],
      }
    }

    exec { 'run puppet to apply bullseye catalog':
      #run puppet to apply bullseye catalog without purging certs
      command   => "/usr/bin/choom -n -1000 -- /usr/local/bin/puppet agent --certname $::hostname.maadix.org --test --skip_tags letsencrypt::certonly >> $directory/logs/posbullseye 2>&1",
      logoutput => true,
      # --test option implies --detailed-exitcodes. and Exitcode of 2 means that The run succeeded, and some resources were changed
      returns   => 2,
      timeout   => 7200,
    }

    exec { 'iptables apache accept':
      command   => "/bin/bash -c '$directory/iptables_apache_accept.sh >> $directory/logs/posbullseye 2>&1'",
      logoutput => true,
      require   =>[
                  Exec['run puppet to apply bullseye catalog'],
                  ],
    } ->
    exec { 'system background wait 2':
      command   => "/bin/bash -c '/etc/maadix/scripts/system_background_wait.sh >> $directory/logs/posbullseye 2>&1'",
      logoutput => true,
      timeout   => 7200,
    } ->
    exec { 'system background stop 2':
      command   => "/bin/bash -c '/etc/maadix/scripts/system_background_stop.sh >> $directory/logs/posbullseye 2>&1'",
      logoutput => true,
      timeout   => 7200,
    } ->
    exec { 'activate all groups':
      command   => "/bin/bash -c '$directory/activate_groups.sh >> $directory/logs/posbullseye 2>&1'",
      logoutput => true,
    } ->
    exec { 'run puppet after groups reactivating':
      command   => "/usr/bin/choom -n -1000 -- /usr/local/bin/puppet agent --certname $::hostname.maadix.org --test >> $directory/logs/posbullseye 2>&1",
      logoutput => true,
      # --test option implies --detailed-exitcodes. and Exitcode of 2 means that The run succeeded, and some resources were changed
      returns   => 2,
      timeout   => 7200,
    } ->
    exec { 'clean apt after groups reactivating':
      command => '/usr/bin/apt-get clean',
    } ->
    exec { 'system background wait 3':
      command   => "/bin/bash -c '/etc/maadix/scripts/system_background_wait.sh >> $directory/logs/posbullseye 2>&1'",
      logoutput => true,
      timeout   => 7200,
    } ->
    exec { 'system background stop 3':
      command   => "/bin/bash -c '/etc/maadix/scripts/system_background_stop.sh >> $directory/logs/posbullseye 2>&1'",
      logoutput => true,
      timeout   => 7200,
    } ->
    exec { 'deactivate deactivated groups':
      command   => "/bin/bash -c '$directory/deactivate_groups.sh >> $directory/logs/posbullseye 2>&1'",
      logoutput => true,
    } ->
    exec { 'run puppet after groups deactivating':
      command   => "/usr/bin/choom -n -1000 -- /usr/local/bin/puppet agent --certname $::hostname.maadix.org --test >> $directory/logs/posbullseye 2>&1",
      logoutput => true,
      # --test option implies --detailed-exitcodes. and Exitcode of 2 means that The run succeeded, and some resources were changed
      returns   => 2,
      timeout   => 7200,
    } ->
    exec { 'delete_obsolete_packages.sh':
      command   => "/bin/bash -c '$directory/delete_obsolete_packages.sh >> $directory/logs/posbullseye 2>&1'",
      timeout   => 3600,
      logoutput => true,
    } ->
    exec { 'system background wait 4':
      command   => "/bin/bash -c '/etc/maadix/scripts/system_background_wait.sh >> $directory/logs/posbullseye 2>&1'",
      logoutput => true,
      timeout   => 7200,
    } ->
    exec { 'system background stop 4':
      command   => "/bin/bash -c '/etc/maadix/scripts/system_background_stop.sh >> $directory/logs/posbullseye 2>&1'",
      logoutput => true,
      timeout   => 7200,
    } ->
    exec { 'run puppet after removing obsolete packages':
      command   => "/usr/bin/choom -n -1000 -- /usr/local/bin/puppet agent --certname $::hostname.maadix.org --test >> $directory/logs/posbullseye 2>&1",
      logoutput => true,
      # --test option implies --detailed-exitcodes. and Exitcode of 2 means that The run succeeded, and some resources were changed
      returns   => 2,
      timeout   => 7200,
    } ->
    exec { 'set_ready_api 2':
      command   => "/bin/bash -c '$directory/set_ready_api.sh >> $directory/logs/posbullseye 2>&1'",
      logoutput => true,
    }->
    #remove maadixbullseye user and group
    user { 'maadixbullseye':
      ensure    => 'absent',
    }->
    group { 'maadixbullseye':
      ensure    => 'absent',
    }->
    #remove maadixbullseye home
    file {'/home/maadixbullseye':
      ensure    => absent,
      recurse   => true,
      purge     => true,
      force     => true,
    }->    
    #remove maadixbullseye sudo
    file { '/etc/sudoers.d/10_maadixbullseye':
      ensure    => 'absent',
    }


    #clean unused images and containers
    if ($::docker_group){
      exec { 'clean docker after apply bullseye catalog':
        command   => '/usr/bin/docker run --rm --userns host -v /var/run/docker.sock:/var/run/docker.sock -v /etc:/etc -e GRACE_PERIOD_SECONDS=1800 spotify/docker-gc',
        logoutput => true,
      }
    }

    exec { 'send cpanel to ready':
      command   => '/etc/init.d/setreadycpanel restart',
    }

    exec { 'disable and remove script posbullseye':
      command   => '/usr/sbin/update-rc.d posbullseye remove && /bin/rm /etc/init.d/posbullseye && /bin/rm -r /etc/systemd/system/posbullseye.service.d',
    }

    exec { 'delete persistent iptables rules':
      command   => '/bin/rm /etc/iptables/*',
      onlyif    => 'ls -l /etc/iptables/* | grep rules',
      path      => ['/usr/bin','/usr/sbin','/bin','/sbin'],
    }

    exec { 'system background start':
      command   => "/bin/bash -c '/etc/maadix/scripts/system_background_start.sh >> $directory/logs/posbullseye 2>&1'",
      logoutput => true,
      timeout   => 7200,
    }

    exec { 'send report':
      command   => "/bin/bash -c '$directory/send_posbullseye_report.sh'",
    }

    exec { 'send posbullseye notify':
      command   => "/bin/bash -c '$directory/send_posbullseye_notify.sh'",
      logoutput => true,
      require   =>[
                  Exec['set_ready_api 2'],
                  ],
    } ->
    exec { 'enable setreadycpanel':
      command   => '/bin/systemctl enable setreadycpanel',
    }


  }

}
