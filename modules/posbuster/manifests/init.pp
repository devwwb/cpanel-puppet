class posbuster (
  $enabled = str2bool("$::posbuster"),
  $directory = '/etc/maadix/buster',
) {

  validate_bool($enabled)

  if $enabled {

    #define scripts
    $scripts = ['delete_obsolete_packages.sh',
                'update_docker.sh',
                'activate_groups.sh',
                'deactivate_groups.sh',
                'iptables_apache_accept.sh',
                'send_posbuster_notify.sh']
    $scripts.each |String $script| {
      file {"$directory/${script}":
        owner   => 'root',
        group   => 'root',
        mode    => '0700',
        content => template("posbuster/${script}"),
      }
    }

    exec { 'iptables apache drop':
      command   => "/bin/bash -c '$directory/iptables_apache_drop.sh > $directory/logs/00_iptables_apache_drop 2>&1'",
      logoutput => true,
    }

    #clean downloaded packages
    exec { 'clean apt':
      command => '/usr/bin/apt-get clean',
    }

    #clean unused images and containers
    if ($::docker_group){
      exec { 'clean docker before apply buster catalog':
        command   => '/usr/bin/docker run --rm --userns host -v /var/run/docker.sock:/var/run/docker.sock -v /etc:/etc -e GRACE_PERIOD_SECONDS=10 spotify/docker-gc',
        logoutput => true,
      }
    }

    if ($::docker_group){
      exec { 'update docker':
        command   => "/bin/bash -c '$directory/update_docker.sh > $directory/logs/02_update_docker 2>&1'",
        logoutput => true,
        timeout   => 1800,
      }

    }

    exec { 'run puppet to apply buster catalog':
      command   => "/usr/local/bin/puppet agent --certname $::hostname.maadix.org --test > $directory/logs/06_run_puppet 2>&1",
      logoutput => true,
      # --test option implies --detailed-exitcodes. and Exitcode of 2 means that The run succeeded, and some resources were changed
      returns   => 2,
      timeout   => 7200,
    }

    if ($::discourse_group){
      exec { 'rebuild discourse':
        command   => "/bin/bash -c 'sudo /var/discourse/launcher rebuild app > $directory/logs/07_rebuild_discourse 2>&1'",
        logoutput => true,
        require   =>[
                    Exec['run puppet to apply buster catalog'],
                    ],
        timeout   => 7200,
      }

    }

    exec { 'iptables apache accept':
      command   => "/bin/bash -c '$directory/iptables_apache_accept.sh > $directory/logs/11_iptables_apache_accept 2>&1'",
      logoutput => true,
      require   =>[
                  Exec['run puppet to apply buster catalog'],
                  ],
    }
    
    exec { 'activate all groups':
      command   => "/bin/bash -c '$directory/activate_groups.sh > $directory/logs/08_activate_groups 2>&1'",
      logoutput => true,
      require   =>[
                  Exec['run puppet to apply buster catalog'],
                  ],
    } ->
    exec { 'run puppet after groups reactivating':
      command   => "/usr/local/bin/puppet agent --certname $::hostname.maadix.org --test > $directory/logs/09_run_puppet_after_group_activation 2>&1",
      logoutput => true,
      # --test option implies --detailed-exitcodes. and Exitcode of 2 means that The run succeeded, and some resources were changed
      returns   => 2,
      require   =>[
                  Exec['run puppet to apply buster catalog'],
                  ],
      timeout   => 7200,
    }

    exec { 'deactivate deactivated groups':
      command   => "/bin/bash -c '$directory/deactivate_groups.sh > $directory/logs/09_1_deactivate_groups 2>&1'",
      logoutput => true,
      require   =>[
                  Exec['run puppet after groups reactivating'],
                  ],
    } ->
    exec { 'run puppet after groups deactivating':
      command   => "/usr/local/bin/puppet agent --certname $::hostname.maadix.org --test > $directory/logs/09_2_run_puppet_after_group_deactivation 2>&1",
      logoutput => true,
      # --test option implies --detailed-exitcodes. and Exitcode of 2 means that The run succeeded, and some resources were changed
      returns   => 2,
      require   =>[
                  Exec['deactivate deactivated groups'],
                  ],
      timeout   => 7200,
    }


    exec { 'delete_obsolete_packages.sh':
      command   => "/bin/bash -c '$directory/delete_obsolete_packages.sh > $directory/logs/09_3_delete_obsolete_packages 2>&1'",
      timeout   => 3600,
      logoutput => true,
      require   =>[
                  Exec['run puppet after groups deactivating'],
                  ],
    }

    #clean unused images and containers
    if ($::docker_group){
      exec { 'clean docker after apply buster catalog':
        command   => '/usr/bin/docker run --rm --userns host -v /var/run/docker.sock:/var/run/docker.sock -v /etc:/etc -e GRACE_PERIOD_SECONDS=10 spotify/docker-gc',
        logoutput => true,
      }
    }

    exec { 'send cpanel to ready':
      command   => '/etc/init.d/setreadycpanel restart',
    }

    exec { 'disable and remove script posbuster':
      command   => '/usr/sbin/update-rc.d posbuster remove && /bin/rm /etc/init.d/posbuster',
    }

    exec { 'delete persistent iptables rules':
      command   => '/bin/rm /etc/iptables/*',
    }

    exec { 'send report':
      command   => "/bin/bash -c '$directory/send_report.sh'",
    }

    exec { 'send posbuster notify':
      command   => "/bin/bash -c '$directory/send_posbuster_notify.sh'",
      logoutput => true,
      require   =>[
                  Exec['run puppet after groups deactivating'],
                  ],
    }


  }

}
