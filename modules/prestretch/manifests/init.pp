class prestretch (
  $enabled = str2bool("$::prestretch"),
  $extlinux = str2bool("$::extlinux"),
  $directory = '/etc/maadix/stretch',
) {

  validate_bool($enabled)

  if $enabled {

    ##stretch scripts directory
    file { "$directory":
      ensure => directory,
      mode   => '0700',
    }
    file { "$directory/logs":
      ensure => directory,
      mode   => '0700',
    }

    #define scripts
    $scripts = ['deactivate_groups_and_run_puppet.sh','iptables_apache_drop.sh','delete_cpanel_cron.sh', 'update_mongodb_34.sh', 'update_postgresql_96.sh', 'delete_mailman_venv_34.sh', 'delete_global_nodejs.sh', 'delete_onlyoffice_image.sh', 'upgrade_jessie.sh', 'update_source_debian.sh', 'update_source_docker.sh', 'update_source_lool.sh', 'update_source_mongodb.sh', 'delete_jessie_sources.sh', 'delete_jessie_packages.sh', 'delete_phpmyadmin.sh', 'upgrade_stretch.sh', 'update_mongodb_36.sh', 'delete_obsolete_packages.sh', 'update_onecontext.sh', 'update_puppet.sh', 'update_bootloader.sh','send_report.sh','send_prestretch_notify.sh']
    $scripts.each |String $script| {
      file {"$directory/${script}":
        owner   => 'root',
        group   => 'root',
        mode    => '0700',
        content => template("prestretch/${script}"),
      }
    }

    exec { 'deactivate groups and run puppet':
      command   => "/bin/bash -c '$directory/deactivate_groups_and_run_puppet.sh > $directory/logs/00_deactivate_groups_and_run_puppet 2>&1'",
      logoutput => true,
    }

    exec { 'iptables apache drop':
      command   => "/bin/bash -c '$directory/iptables_apache_drop.sh > $directory/logs/01_iptables_apache_drop 2>&1'",
      logoutput => true,
      require   =>[
                  Exec['deactivate groups and run puppet'],
                  ],
    }

    exec { 'delete cpanel cron':
      command   => "/bin/bash -c '$directory/delete_cpanel_cron.sh > $directory/logs/02_delete_cpanel_cron 2>&1'",
      logoutput => true,
      require   =>[
                  Exec['deactivate groups and run puppet'],
                  ],
    }

    if ($::mongodb_group){
      exec { 'update mongodb 3.4':
        command   => "/bin/bash -c '$directory/update_mongodb_34.sh > $directory/logs/03_update_mongodb_34 2>&1'",
        logoutput => true,
        require   =>[
                    Exec['deactivate groups and run puppet'],
                    ],
      }
    }

    if ($::postgresql_group){
      exec { 'update postgresql 9.6':
        command   => "/bin/bash -c '$directory/update_postgresql_96.sh > $directory/logs/04_update_postgresql_96 2>&1'",
        logoutput => true,
        require   =>[
                    Exec['deactivate groups and run puppet'],
                    ],
      }
    }

    if ($::mailman_venv3_group){
      exec { 'delete mailman venv 3.4':
        command   => "/bin/bash -c '$directory/delete_mailman_venv_34 > $directory/logs/05_delete_mailman_venv_34 2>&1'",
        logoutput => true,
        require   =>[
                    Exec['deactivate groups and run puppet'],
                    ],
      }
    }

    if ($::nodejs_group){
      exec { 'delete global nodejs':
        command   => "/bin/bash -c '$directory/delete_global_nodejs.sh > $directory/logs/06_delete_global_nodejs 2>&1'",
        logoutput => true,
        require   =>[
                    Exec['deactivate groups and run puppet'],
                    ],
      }
    }

    if ($::onlyoffice_group){
      exec { 'delete onlyoffice image':
        command   => "/bin/bash -c '$directory/delete_onlyoffice_image.sh > $directory/logs/07_delete_onlyoffice_image 2>&1'",
        logoutput => true,
        require   =>[
                    Exec['deactivate groups and run puppet'],
                    ],
      }
    }

    exec { 'upgrade jessie':
      command   => "/bin/bash -c '$directory/upgrade_jessie.sh > $directory/logs/08_upgrade_jessie 2>&1'",
      logoutput => true,
      require   =>[
                  Exec['deactivate groups and run puppet'],
                  ],
    }

    
    exec { 'update source debian':
      command   => "/bin/bash -c '$directory/update_source_debian.sh > $directory/logs/09_update_source_debian 2>&1'",
      logoutput => true,
      require   =>[
                  Exec['upgrade jessie'],
                  ],
    }

    if ($::mongodb_group){
      exec { 'update source mongodb':
        command   => "/bin/bash -c '$directory/update_source_mongodb.sh > $directory/logs/10_update_source_mongodb 2>&1'",
        logoutput => true,
        require   =>[
                    Exec['upgrade jessie'],
                    ],
      }
    }

    if ($::lool_group){
      exec { 'update source lool':
        command   => "/bin/bash -c '$directory/update_source_lool.sh > $directory/logs/11_update_source_lool 2>&1'",
        logoutput => true,
        require   =>[
                    Exec['upgrade jessie'],
                    ],
      }
    }

    if ($::docker_group){
      exec { 'update source docker':
        command   => "/bin/bash -c '$directory/update_source_docker.sh > $directory/logs/12_update_source_docker 2>&1'",
        logoutput => true,
        require   =>[
                    Exec['upgrade jessie'],
                    ],
      }
    }

    exec { 'delete jessie sources':
      command   => "/bin/bash -c '$directory/delete_jessie_sources.sh > $directory/logs/13_delete_jessie_sources 2>&1'",
      logoutput => true,
      require   =>[
                  Exec['upgrade jessie'],
                  ],
    }

    exec { 'delete jessie packages':
      command   => "/bin/bash -c '$directory/delete_jessie_packages.sh > $directory/logs/14_delete_jessie_packages 2>&1'",
      logoutput => true,
      require   =>[
                  Exec['upgrade jessie'],
                  ],
    }

    if ($::phpmyadmin_group){
      exec { 'delete phpmyadmin':
        command   => "/bin/bash -c '$directory/delete_phpmyadmin.sh > $directory/logs/15_delete_phpmyadmin 2>&1'",
        logoutput => true,
        require   =>[
                    Exec['upgrade jessie'],
                    ],
      }
    }

    exec { 'upgrade stretch':
      command   => "/bin/bash -c '$directory/upgrade_stretch.sh > $directory/logs/16_upgrade_stretch 2>&1'",
      logoutput => true,
      timeout   => 1800,
      require   =>[
                  Exec['upgrade jessie'],
                  ],
    }

    exec { 'restart postfix':
      command   => '/usr/sbin/service postfix restart',
      logoutput => true,
    }

    if ($::mongodb_group){
      exec { 'update mongodb 3.6':
        command   => "/bin/bash -c '$directory/update_mongodb_36.sh > $directory/logs/17_update_mongodb_36 2>&1'",
        logoutput => true,
        require   =>[
                    Exec['upgrade stretch'],
                    ],
      }
    }

    exec { 'delete obsolete packages':
      command   => "/bin/bash -c '$directory/delete_obsolete_packages.sh > $directory/logs/18_delete_obsolete_packages 2>&1'",
      logoutput => true,
      require   =>[
                  Exec['upgrade stretch'],
                  ],
    }

    exec { 'update onecontext':
      command   => "/bin/bash -c '$directory/update_onecontext.sh > $directory/logs/19_update_onecontext 2>&1'",
      logoutput => true,
      require   =>[
                  Exec['upgrade stretch'],
                  ],
    }

    exec { 'update puppet':
      command   => "/bin/bash -c '$directory/update_puppet.sh > $directory/logs/20_update_puppet 2>&1'",
      logoutput => true,
      require   =>[
                  Exec['upgrade stretch'],
                  ],
    }

    #if extlinux is the bootloader, replace by grub
    if ($extlinux) {
      exec { 'update bootloader':
        command   => "/bin/bash -c '$directory/update_bootloader.sh > $directory/logs/21_update_bootloader 2>&1'",
        logoutput => true,
        require   =>[
                    Exec['upgrade stretch'],
                    ],
      }
    }

    file {"/etc/init.d/posstretch":
      owner   => 'root',
      group   => 'root',
      mode    => '0700',
      content => template("prestretch/posstretch_init"),
    } ->
    exec { 'activate posstretch init':
      command   => "/bin/bash -c 'update-rc.d posstretch defaults 99'",
      logoutput => true,
      require   =>[
                  Exec['upgrade stretch'],
                  ],
    }

    exec { 'send report':
      command   => "/bin/bash -c '$directory/send_report.sh'",
    }

    exec { 'send prestretch notify':
      command   => "/bin/bash -c '$directory/send_prestretch_notify.sh'",
      require   =>[
                  Exec['upgrade stretch'],
                  ],
    }

    #if extlinux is the bootloader, it's a kvm guest. shutdown the vm to replace network init scripts
    if ($extlinux) {
      exec { 'shutdown vm':
        command   => "/bin/bash -c '/lib/molly-guard/shutdown -h +2 &'",
        logoutput => true,
        require   =>[
                  Exec['upgrade stretch'],
                  ],
      }
    #if grub is the bootloader, it's a dedicated. reboot the server
    } else {
      exec { 'reboot server':
        command   => "/bin/bash -c '/lib/molly-guard/shutdown -r +2 &'",
        logoutput => true,
        require   =>[
                  Exec['upgrade stretch'],
                  ],
      }
    }
 
  }

}
