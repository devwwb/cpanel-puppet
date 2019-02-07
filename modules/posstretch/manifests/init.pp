class posstretch (
  $enabled = str2bool("$::posstretch"),
  $directory = '/etc/maadix/stretch',
) {

  validate_bool($enabled)

  if $enabled {

    #define scripts
    $scripts = ['delete_obsolete_packages.sh','update_docker.sh','update_facts_classifier.sh','activate_groups.sh','restore_cpanel_cron.sh','iptables_apache_accept.sh','send_posstretch_notify.sh']
    $scripts.each |String $script| {
      file {"$directory/${script}":
        owner   => 'root',
        group   => 'root',
        mode    => '0700',
        content => template("posstretch/${script}"),
      }
    }

    exec { 'iptables apache drop':
      command   => "/bin/bash -c '$directory/iptables_apache_drop.sh > $directory/logs/00_iptables_apache_drop 2>&1'",
      logoutput => true,
    }


    if ($::docker_group){
      exec { 'update docker':
        command   => "/bin/bash -c '$directory/update_docker.sh > $directory/logs/02_update_docker 2>&1'",
        logoutput => true,
      }

      exec { 'delete old aufs docker images':
        command   => "/bin/bash -c 'docker image prune -a > $directory/logs/03_delete_old_aufs_docker_images 2>&1'",
        logoutput => true,
      }

    }

    exec { 'update facts classifier':
      command   => "/bin/bash -c '$directory/update_facts_classifier.sh > $directory/logs/05_update_facts_classifier 2>&1'",
      logoutput => true,
    } ->
    exec { 'run puppet to apply stretch catalog':
      command   => "/usr/local/bin/puppet agent --test > $directory/logs/06_run_puppet 2>&1",
      logoutput => true,
      # --test option implies --detailed-exitcodes. and Exitcode of 2 means that The run succeeded, and some resources were changed
      returns   => 2,
      timeout   => 3600,
    }

    if ($::discourse_group){
      exec { 'rebuild discourse':
        command   => "/bin/bash -c 'sudo /var/discourse/launcher rebuild app > $directory/logs/07_rebuild_discourse 2>&1'",
        logoutput => true,
        require   =>[
                    Exec['run puppet to apply stretch catalog'],
                    ],
        timeout   => 3600,
      }

    }

    exec { 'activate groups':
      command   => "/bin/bash -c '$directory/activate_groups.sh > $directory/logs/08_activate_groups 2>&1'",
      logoutput => true,
      require   =>[
                  Exec['run puppet to apply stretch catalog'],
                  ],
    } ->
    exec { 'run puppet after groups reactivating':
      command   => "/usr/local/bin/puppet agent --test > $directory/logs/09_run_puppet_after_group_activation 2>&1",
      logoutput => true,
      # --test option implies --detailed-exitcodes. and Exitcode of 2 means that The run succeeded, and some resources were changed
      returns   => 2,
      require   =>[
                  Exec['run puppet to apply stretch catalog'],
                  ],
      timeout   => 3600,
    }

    exec { 'delete_obsolete_packages.sh':
      command   => "/bin/bash -c '$directory/delete_obsolete_packages.sh > $directory/logs/091_delete_obsolete_packages 2>&1'",
      logoutput => true,
      require   =>[
                  Exec['run puppet after groups reactivating'],
                  ],
    }

    exec { 'restore cpanel cron':
      command   => "/bin/bash -c '$directory/restore_cpanel_cron.sh > $directory/logs/10_restore_cpanel_cron 2>&1'",
      logoutput => true,
      require   =>[
                  Exec['run puppet after groups reactivating'],
                  ],
    }

    exec { 'iptables apache accept':
      command   => "/bin/bash -c '$directory/iptables_apache_accept.sh > $directory/logs/11_iptables_apache_accept 2>&1'",
      logoutput => true,
      require   =>[
                  Exec['run puppet after groups reactivating'],
                  ],
    }

    exec { 'send cpanel to ready':
      command   => '/etc/init.d/setreadycpanel restart',
    }

    exec { 'disable and remove script posstretch':
      command   => '/usr/sbin/update-rc.d posstretch remove && /bin/rm /etc/init.d/posstretch',
    }

    exec { 'delete persistent iptables rules':
      command   => '/bin/rm /etc/iptables/*',
    }

    exec { 'send report':
      command   => "/bin/bash -c '$directory/send_report.sh'",
    }

    exec { 'send posstretch notify':
      command   => "/bin/bash -c '$directory/send_posstretch_notify.sh'",
      logoutput => true,
      require   =>[
                  Exec['run puppet after groups reactivating'],
                  ],
    }


  }

}
