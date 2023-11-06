class prebullseye (
  $enabled = str2bool("$::prebullseye"),
  $extlinux = str2bool("$::extlinux"),
  $directory = '/etc/maadix/bullseye',
  $disablereboot = str2bool("$::disablereboot"),
) {

  validate_bool($enabled)

  if $enabled {

    ##bullseye scripts directory
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
                'update_mongodb_50.sh', 
                'delete_mailman_venv_37.sh', 
                'delete_odoo_venv_37.sh',
                'delete_onlyoffice_image.sh', 
                'fix_sury_packages.sh',
                'upgrade_buster.sh', 
                'update_source_debian.sh', 
                'update_source_docker.sh', 
                'update_source_lool.sh', 
                'update_source_mongodb.sh', 
                'delete_buster_packages.sh', 
                'delete_mxcp.sh',
                'upgrade_bullseye.sh', 
                'update_postgresql_13.sh',
                'update_onecontext.sh', 
                'send_prebullseye_report.sh',
                'send_prebullseye_notify.sh']
    $scripts.each |String $script| {
      file {"$directory/${script}":
        owner   => 'root',
        group   => 'root',
        mode    => '0700',
        content => template("prebullseye/${script}"),
      }
    }

    exec { 'reset prebullseye log':
      command   => "/bin/rm $directory/logs/prebullseye",
      onlyif    => "/usr/bin/test -f $directory/logs/prebullseye",
    } ->
    exec { 'backup mysql':
      command   => "/bin/bash -c '$directory/backup_mysql.sh >> $directory/logs/prebullseye 2>&1'",
      logoutput => true,
      timeout   => 1800,
    } ->
    exec { 'deactivate groups and run puppet':
      command   => "/bin/bash -c '$directory/deactivate_groups_and_run_puppet.sh >> $directory/logs/prebullseye 2>&1'",
      logoutput => true,
      timeout   => 3600,
    } ->
    exec { 'iptables apache drop':
      command   => "/bin/bash -c '$directory/iptables_apache_drop.sh >> $directory/logs/prebullseye 2>&1'",
      logoutput => true,
    } ->
    exec { 'update mongodb 5.0':
        command   => "/bin/bash -c '$directory/update_mongodb_50.sh >> $directory/logs/prebullseye 2>&1'",
        logoutput => true,
        timeout   => 1800,
        onlyif    => 'test -f /usr/bin/mongod',
        path      => ['/usr/bin','/usr/sbin','/bin','/sbin'],
    }

    if ($::mailman_venv3_group){
      exec { 'delete mailman venv 3.7':
        command   => "/bin/bash -c '$directory/delete_mailman_venv_37.sh >> $directory/logs/prebullseye 2>&1'",
        logoutput => true,
        require   =>[
                    Exec['deactivate groups and run puppet'],
                    ],
      }
    }

    if ($::odoo_venv3_group){
      exec { 'delete odoo venv 3.7':
        command   => "/bin/bash -c '$directory/delete_odoo_venv_37.sh >> $directory/logs/prebullseye 2>&1'",
        logoutput => true,
        require   =>[
                    Exec['deactivate groups and run puppet'],
                    ],
      }
    }


    if ($::onlyoffice_group){
      exec { 'delete onlyoffice image':
        command   => "/bin/bash -c '$directory/delete_onlyoffice_image.sh >> $directory/logs/prebullseye 2>&1'",
        logoutput => true,
        require   =>[
                    Exec['deactivate groups and run puppet'],
                    ],
      }
    }

    #delete buster packages
    /* TODO
    exec { 'delete buster packages':
      command   => "/bin/bash -c '$directory/delete_buster_packages.sh >> $directory/logs/prebullseye 2>&1'",
      logoutput => true,
      timeout   => 3600,
      require   =>[
                  Exec['update mongodb 4.2'],
                  ],
    } ->
    */
    exec { 'upgrade buster':
      command   => "/bin/bash -c '$directory/upgrade_buster.sh >> $directory/logs/prebullseye 2>&1'",
      logoutput => true,
      timeout   => 3600,
    } ->
    exec { 'iptables apache drop after buster upgrade':
      command   => "/bin/bash -c '$directory/iptables_apache_drop.sh >> $directory/logs/prebullseye 2>&1'",
      logoutput => true,
    } ->
    exec { 'update source debian':
      command   => "/bin/bash -c '$directory/update_source_debian.sh >> $directory/logs/prebullseye 2>&1'",
      logoutput => true,
    } ->
    exec { 'update source sury':
      command   => "/bin/bash -c '$directory/update_source_sury.sh >> $directory/logs/prebullseye 2>&1'",
      logoutput => true,
      require   =>[
                  Exec['upgrade stretch'],
                  ],
    }

    if ($::lool_group){
      exec { 'update source lool':
        command   => "/bin/bash -c '$directory/update_source_lool.sh >> $directory/logs/prebullseye 2>&1'",
        logoutput => true,
        require   =>[
                    Exec['upgrade stretch'],
                    ],
      }
    }

    if ($::docker_group){
      exec { 'update source docker':
        command   => "/bin/bash -c '$directory/update_source_docker.sh >> $directory/logs/prebullseye 2>&1'",
        logoutput => true,
        require   =>[
                    Exec['upgrade stretch'],
                    ],
      }
    }


    exec { 'delete mxcp':
      command   => "/bin/bash -c '$directory/delete_mxcp.sh >> $directory/logs/prebullseye 2>&1'",
      logoutput => true,
      require   =>[
                  Exec['upgrade stretch'],
                  ],
    }

    exec { 'upgrade bullseye':
      command   => "/bin/bash -c '$directory/upgrade_bullseye.sh >> $directory/logs/prebullseye 2>&1'",
      logoutput => true,
      timeout   => 7200,
    } ->
    exec { 'iptables apache drop after bullseye upgrade':
      command   => "/bin/bash -c '$directory/iptables_apache_drop.sh >> $directory/logs/prebullseye 2>&1'",
      logoutput => true,
    } ->
    exec { 'restart postfix':
      command   => '/usr/sbin/service postfix restart',
      logoutput => true,
    } ->
    exec { 'update postgresql 13':
      command   => "/bin/bash -c '$directory/update_postgresql_13.sh >> $directory/logs/prebullseye 2>&1'",
      logoutput => true,
      timeout   => 1800,
    }

    #update one-context
    if ($::one_context) {
      exec { 'update onecontext':
        command   => "/bin/bash -c '$directory/update_onecontext.sh >> $directory/logs/prebullseye 2>&1'",
        logoutput => true,
        timeout   => 1800,
        require   =>[
                    Exec['upgrade bullseye'],
                    ],
      }
    }

    #posbullseye script
    file {"/etc/init.d/posbullseye":
      owner   => 'root',
      group   => 'root',
      mode    => '0700',
      content => template("prebullseye/posbullseye_init"),
    } ->
    exec { 'activate posbullseye init':
      command   => "/bin/bash -c 'update-rc.d posbullseye defaults 99'",
      logoutput => true,
      require   =>[
                  Exec['upgrade bullseye'],
                  ],
    } ->
    file {'/etc/systemd/system/posbullseye.service.d':
      ensure   => directory,
    } ->
    file {'/etc/systemd/system/posbullseye.service.d/deps.conf':
      content => template("prebullseye/posbullseye_init_deps"),
    }


    exec { 'delete persistent iptables rules':
      command   => '/bin/rm /etc/iptables/*',
      onlyif    => 'ls -l /etc/iptables/* | grep rules',
      path      => ['/usr/bin','/usr/sbin','/bin','/sbin'],
    }

    exec { 'send report':
      command   => "/bin/bash -c '$directory/send_prebullseye_report.sh'",
    }

    exec { 'disable setreadycpanel':
      command   => '/bin/systemctl disable setreadycpanel',
      require   =>[
                  Exec['upgrade bullseye'],
                  ],
    } ->
    exec { 'send prebullseye notify':
      command   => "/bin/bash -c '$directory/send_prebullseye_notify.sh  && sleep 120'",
    }

    #reboot the server unless $disablereboot==true
    if $disablereboot {

      notify { 'reboot server disabled': }

    } else {

      exec { 'reboot server':
          command   => "/bin/bash -c '/lib/molly-guard/shutdown -r now' &",
          logoutput => true,
          require   =>[
                      Exec['upgrade bullseye'],
                      Exec['update postgresql 13'],
                      ],
      }

    }
 
  }

}
