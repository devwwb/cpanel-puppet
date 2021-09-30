class prebuster (
  $enabled = str2bool("$::prebuster"),
  $extlinux = str2bool("$::extlinux"),
  $directory = '/etc/maadix/buster',
) {

  validate_bool($enabled)

  if $enabled {

    ##buster scripts directory
    file { "$directory":
      ensure => directory,
      mode   => '0700',
    }
    file { "$directory/logs":
      ensure => directory,
      mode   => '0700',
    }

    #define scripts
    $scripts = ['backup_mysql.sh',
                'deactivate_groups_and_run_puppet.sh',
                'iptables_apache_drop.sh',
                'update_mongodb_42.sh', 
                'delete_mailman_venv_35.sh', 
                'delete_onlyoffice_image.sh', 
                'fix_sury_packages.sh',
                'upgrade_stretch.sh', 
                'update_source_debian.sh', 
                'update_source_docker.sh', 
                'update_source_lool.sh', 
                'update_source_mongodb.sh', 
                'delete_stretch_sources.sh', 
                'delete_stretch_packages.sh', 
                'delete_mxcp.sh',
                'delete_phpmyadmin.sh', 
                'upgrade_buster.sh', 
                'update_postgresql_11.sh',
                'update_onecontext.sh', 
                'send_prebuster_report.sh',
                'send_prebuster_notify.sh']
    $scripts.each |String $script| {
      file {"$directory/${script}":
        owner   => 'root',
        group   => 'root',
        mode    => '0700',
        content => template("prebuster/${script}"),
      }
    }

    exec { 'reset prebuster log':
      command   => "/bin/rm $directory/logs/prebuster",
      onlyif    => "/usr/bin/test -f $directory/logs/prebuster",
    } ->
    exec { 'backup mysql':
      command   => "/bin/bash -c '$directory/backup_mysql.sh >> $directory/logs/prebuster 2>&1'",
      logoutput => true,
      timeout   => 1800,
    } ->
    exec { 'deactivate groups and run puppet':
      command   => "/bin/bash -c '$directory/deactivate_groups_and_run_puppet.sh >> $directory/logs/prebuster 2>&1'",
      logoutput => true,
      timeout   => 3600,
    } ->
    exec { 'iptables apache drop':
      command   => "/bin/bash -c '$directory/iptables_apache_drop.sh >> $directory/logs/prebuster 2>&1'",
      logoutput => true,
    } ->
    exec { 'update mongodb 4.2':
        command   => "/bin/bash -c '$directory/update_mongodb_42.sh >> $directory/logs/prebuster 2>&1'",
        logoutput => true,
        timeout   => 1800,
        onlyif    => 'test -f /usr/bin/mongod',
        path      => ['/usr/bin','/usr/sbin','/bin','/sbin'],
    }

    if ($::mailman_venv3_group){
      exec { 'delete mailman venv 3.5':
        command   => "/bin/bash -c '$directory/delete_mailman_venv_35.sh >> $directory/logs/prebuster 2>&1'",
        logoutput => true,
        require   =>[
                    Exec['deactivate groups and run puppet'],
                    ],
      }
    }


    if ($::onlyoffice_group){
      exec { 'delete onlyoffice image':
        command   => "/bin/bash -c '$directory/delete_onlyoffice_image.sh >> $directory/logs/prebuster 2>&1'",
        logoutput => true,
        require   =>[
                    Exec['deactivate groups and run puppet'],
                    ],
      }
    }

    exec { 'delete stretch packages':
      command   => "/bin/bash -c '$directory/delete_stretch_packages.sh >> $directory/logs/prebuster 2>&1'",
      logoutput => true,
      require   =>[
                  Exec['update mongodb 4.2'],
                  ],
    } ->
    exec { 'downgrade sury packages to stock packages':
      command   => "/bin/bash -c '$directory/fix_sury_packages.sh >> $directory/logs/prebuster 2>&1'",
      logoutput => true,
      timeout   => 3600,
    } ->
    exec { 'delete stretch sources':
      command   => "/bin/bash -c '$directory/delete_stretch_sources.sh >> $directory/logs/prebuster 2>&1'",
      logoutput => true,
    } ->
    exec { 'upgrade stretch':
      command   => "/bin/bash -c '$directory/upgrade_stretch.sh >> $directory/logs/prebuster 2>&1'",
      logoutput => true,
      timeout   => 3600,
    } ->
    exec { 'iptables apache drop after stretch upgrade':
      command   => "/bin/bash -c '$directory/iptables_apache_drop.sh >> $directory/logs/prebuster 2>&1'",
      logoutput => true,
    } ->
    exec { 'update source debian':
      command   => "/bin/bash -c '$directory/update_source_debian.sh >> $directory/logs/prebuster 2>&1'",
      logoutput => true,
    }

    if ($::mongodb_group){
      exec { 'update source mongodb':
        command   => "/bin/bash -c '$directory/update_source_mongodb.sh >> $directory/logs/prebuster 2>&1'",
        logoutput => true,
        require   =>[
                    Exec['upgrade stretch'],
                    ],
      }
    }

    if ($::lool_group){
      exec { 'update source lool':
        command   => "/bin/bash -c '$directory/update_source_lool.sh >> $directory/logs/prebuster 2>&1'",
        logoutput => true,
        require   =>[
                    Exec['upgrade stretch'],
                    ],
      }
    }

    if ($::docker_group){
      exec { 'update source docker':
        command   => "/bin/bash -c '$directory/update_source_docker.sh >> $directory/logs/prebuster 2>&1'",
        logoutput => true,
        require   =>[
                    Exec['upgrade stretch'],
                    ],
      }
    }


    exec { 'delete mxcp':
      command   => "/bin/bash -c '$directory/delete_mxcp.sh >> $directory/logs/prebuster 2>&1'",
      logoutput => true,
      require   =>[
                  Exec['upgrade stretch'],
                  ],
    }

    if ($::phpmyadmin_group){
      exec { 'delete phpmyadmin':
        command   => "/bin/bash -c '$directory/delete_phpmyadmin.sh >> $directory/logs/prebuster 2>&1'",
        logoutput => true,
        require   =>[
                    Exec['upgrade stretch'],
                    ],
      }
    }

    exec { 'fix innodb mariadb':
      command => "/bin/sed -i -e 's/^innodb_file_format_max/#innodb_file_format_max/' /etc/mysql/my.cnf",
      require   =>[
                  Exec['upgrade stretch'],
                  ],
    } ->
    exec { 'upgrade buster':
      command   => "/bin/bash -c '$directory/upgrade_buster.sh >> $directory/logs/prebuster 2>&1'",
      logoutput => true,
      timeout   => 7200,
    } ->
    exec { 'iptables apache drop after buster upgrade':
      command   => "/bin/bash -c '$directory/iptables_apache_drop.sh >> $directory/logs/prebuster 2>&1'",
      logoutput => true,
    } ->
    exec { 'restart postfix':
      command   => '/usr/sbin/service postfix restart',
      logoutput => true,
    } ->
    exec { 'update postgresql 11':
      command   => "/bin/bash -c '$directory/update_postgresql_11.sh >> $directory/logs/prebuster 2>&1'",
      logoutput => true,
      timeout   => 1800,
    }

    #update one-context
    if ($::one_context) {
      exec { 'update onecontext':
        command   => "/bin/bash -c '$directory/update_onecontext.sh >> $directory/logs/prebuster 2>&1'",
        logoutput => true,
        timeout   => 1800,
        require   =>[
                    Exec['upgrade buster'],
                    ],
      }
    }

    #posbuster script
    file {"/etc/init.d/posbuster":
      owner   => 'root',
      group   => 'root',
      mode    => '0700',
      content => template("prebuster/posbuster_init"),
    } ->
    exec { 'activate posbuster init':
      command   => "/bin/bash -c 'update-rc.d posbuster defaults 99'",
      logoutput => true,
      require   =>[
                  Exec['upgrade buster'],
                  ],
    } ->
    file {'/etc/systemd/system/posbuster.service.d':
      ensure   => directory,
    } ->
    file {'/etc/systemd/system/posbuster.service.d/deps.conf':
      content => template("prebuster/posbuster_init_deps"),
    }


    exec { 'delete persistent iptables rules':
      command   => '/bin/rm /etc/iptables/*',
      onlyif    => 'ls -l /etc/iptables/* | grep rules',
      path      => ['/usr/bin','/usr/sbin','/bin','/sbin'],
    }

    exec { 'send report':
      command   => "/bin/bash -c '$directory/send_prebuster_report.sh'",
    }

    exec { 'disable setreadycpanel':
      command   => '/bin/systemctl disable setreadycpanel',
      require   =>[
                  Exec['upgrade buster'],
                  ],
    } ->
    exec { 'send prebuster notify':
      command   => "/bin/bash -c '$directory/send_prebuster_notify.sh  && sleep 120'",
    }

    #reboot the server
    exec { 'reboot server':
        command   => "/bin/bash -c '/lib/molly-guard/shutdown -r now' &",
        logoutput => true,
        require   =>[
                    Exec['upgrade buster'],
                    Exec['update postgresql 11'],
                    ],
    }
 
  }

}
