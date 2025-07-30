class prebookworm (
  Boolean $enabled = str2bool($facts['prebookworm']),
  $directory       = '/etc/maadix/bookworm',
  $disablereboot   = str2bool($facts['disablereboot']),
  String $hostname = $facts['networking']['hostname'],
  String $email    = 'admin@maadix.org',
) {

  if $enabled {

    ##bookworm scripts directory
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
                'update_mongodb_70.sh',
                'delete_mailman_venv_39.sh',
                'delete_odoo_venv_39.sh',
                'delete_onlyoffice_image.sh',
                'upgrade_bullseye.sh',
                'reload_ldap.sh',
                'update_source_debian.sh',
                'update_source_mongodb.sh',
                'update_source_docker.sh',
                'update_source_lool.sh',
                'update_source_sury.sh',
                'update_source_nginx.sh',
                'update_source_redis.sh',
                'update_source_tor.sh',
                'delete_bullseye_packages.sh',
                'delete_mxcp.sh',
                'upgrade_bookworm.sh',
                'update_source_puppet.sh',
                'update_postgresql_15.sh',
                'send_prebookworm_report.sh',
                'send_prebookworm_notify.sh']
    $scripts.each |String $script| {
      file {"$directory/${script}":
        owner   => 'root',
        group   => 'root',
        mode    => '0700',
        content => template("prebookworm/${script}"),
      }
    }

    #maadixupgrade user
    user { 'maadixupgrade':
      ensure     => 'present',
      home       => '/home/maadixupgrade',
      managehome => true,
      shell      => '/bin/bash',
      password_max_age => '200000',
    }->
    #maadixupgrade authorized_keys
    file {'/home/maadixupgrade/.ssh':
      ensure    => directory,
      group     => 'maadixupgrade',
      owner     => 'maadixupgrade',
      mode      => '0600',
    }->
    file {'/home/maadixupgrade/.ssh/authorized_keys':
      group     => 'maadixupgrade',
      owner     => 'maadixupgrade',
      mode      => '0600',
      source    => 'file:/etc/maadix/authorized_keys',
    }->
    #maadixupgrade sudo
    file { '/etc/sudoers.d/10_maadixupgrade':
      content   => 'maadixupgrade ALL=NOPASSWD: ALL',
    }->
    #start
    exec { 'reset prebookworm log':
      command   => "/bin/rm $directory/logs/prebookworm",
      onlyif    => "/usr/bin/test -f $directory/logs/prebookworm",
    } ->
    exec { 'system background wait 1':
      command   => "/bin/bash -c '/etc/maadix/scripts/system_background_wait.sh >> $directory/logs/prebookworm 2>&1'",
      logoutput => true,
      timeout   => 7200,
    } ->
    exec { 'system background stop 1':
      command   => "/bin/bash -c '/etc/maadix/scripts/system_background_stop.sh >> $directory/logs/prebookworm 2>&1'",
      logoutput => true,
    } ->
    exec { 'backup mysql':
      command   => "/bin/bash -c '$directory/backup_mysql.sh >> $directory/logs/prebookworm 2>&1'",
      logoutput => true,
      timeout   => 3600,
    } ->
    exec { 'clean apt before running puppet':
      command => '/usr/bin/apt-get clean',
    } ->
    exec { 'deactivate groups and run puppet':
      command   => "/bin/bash -c '$directory/deactivate_groups_and_run_puppet.sh >> $directory/logs/prebookworm 2>&1'",
      logoutput => true,
      timeout   => 7200,
    } ->
    exec { 'iptables apache drop':
      command   => "/bin/bash -c '$directory/iptables_apache_drop.sh >> $directory/logs/prebookworm 2>&1'",
      logoutput => true,
    } ->
    exec { 'system background wait 2':
      command   => "/bin/bash -c '/etc/maadix/scripts/system_background_wait.sh >> $directory/logs/prebookworm 2>&1'",
      logoutput => true,
      timeout   => 7200,
    } ->
    exec { 'system background stop 2':
      command   => "/bin/bash -c '/etc/maadix/scripts/system_background_stop.sh >> $directory/logs/prebookworm 2>&1'",
      logoutput => true,
      timeout   => 7200,
    } ->
    exec { 'update mongodb 7.0':
        command   => "/bin/bash -c '$directory/update_mongodb_70.sh >> $directory/logs/prebookworm 2>&1'",
        logoutput => true,
        timeout   => 3600,
        onlyif    => 'test -f /usr/bin/mongod',
        path      => ['/usr/bin','/usr/sbin','/bin','/sbin'],
    }

    if ($facts['mailman_venv3_group']){
      exec { 'delete mailman venv 3.9':
        command   => "/bin/bash -c '$directory/delete_mailman_venv_39.sh >> $directory/logs/prebookworm 2>&1'",
        logoutput => true,
        require   =>[
                    Exec['deactivate groups and run puppet'],
                    ],
      }
    }

    /*
    #odoo 14 does not work in bookworm.
    if ($facts['odoo_venv3_group']){
      exec { 'delete odoo venv 3.9':
        command   => "/bin/bash -c '$directory/delete_odoo_venv_39.sh >> $directory/logs/prebookworm 2>&1'",
        logoutput => true,
        require   =>[
                    Exec['deactivate groups and run puppet'],
                    ],
      }
    }
    */

    /*
    if ($facts['onlyoffice_group']){
      exec { 'delete onlyoffice image':
        command   => "/bin/bash -c '$directory/delete_onlyoffice_image.sh >> $directory/logs/prebookworm 2>&1'",
        logoutput => true,
        timeout   => 3600,
        require   =>[
                    Exec['deactivate groups and run puppet'],
                    ],
      }
    }
    */

    #delete bullseye packages
    exec { 'delete bullseye packages':
      command   => "/bin/bash -c '$directory/delete_bullseye_packages.sh >> $directory/logs/prebookworm 2>&1'",
      logoutput => true,
      timeout   => 3600,
      require   =>[
                  Exec['update mongodb 7.0'],
                  ],
    } ->
    exec { 'reload ldap database':
      command   => "/bin/bash -c '$directory/reload_ldap.sh >> $directory/logs/prebookworm 2>&1'",
      logoutput => true,
      timeout   => 7200,
    } ->
    exec { 'upgrade bullseye':
      command   => "/bin/bash -c '$directory/upgrade_bullseye.sh >> $directory/logs/prebookworm 2>&1'",
      logoutput => true,
      timeout   => 7200,
    } ->
    exec { 'iptables apache drop after bullseye upgrade':
      command   => "/bin/bash -c '$directory/iptables_apache_drop.sh >> $directory/logs/prebookworm 2>&1'",
      logoutput => true,
    } ->
    exec { 'update source debian':
      command   => "/bin/bash -c '$directory/update_source_debian.sh >> $directory/logs/prebookworm 2>&1'",
      logoutput => true,
    } ->
    exec { 'update source redis':
      command   => "/bin/bash -c '$directory/update_source_redis.sh >> $directory/logs/prebookworm 2>&1'",
      logoutput => true,
    } ->
    exec { 'update source sury':
      command   => "/bin/bash -c '$directory/update_source_sury.sh >> $directory/logs/prebookworm 2>&1'",
      logoutput => true,
      require   =>[
                  Exec['upgrade bullseye'],
                  ],
    }

    if ($facts['mongodb_group']){
      exec { 'update source mongodb':
        command   => "/bin/bash -c '$directory/update_source_mongodb.sh >> $directory/logs/prebookworm 2>&1'",
        logoutput => true,
        require   =>[
                    Exec['upgrade bullseye'],
                    ],
      }
    }

    if ($facts['docker_group']){
      exec { 'update source docker':
        command   => "/bin/bash -c '$directory/update_source_docker.sh >> $directory/logs/prebookworm 2>&1'",
        logoutput => true,
        require   =>[
                    Exec['upgrade bullseye'],
                    ],
      }
    }

    if ($facts['nginx_group']){
      exec { 'update source nginx':
        command   => "/bin/bash -c '$directory/update_source_nginx.sh >> $directory/logs/prebookworm 2>&1'",
        logoutput => true,
        require   =>[
                    Exec['upgrade bullseye'],
                    ],
      }
    }

    if ($facts['tor_group']){
      exec { 'update source tor':
        command   => "/bin/bash -c '$directory/update_source_tor.sh >> $directory/logs/prebookworm 2>&1'",
        logoutput => true,
        require   =>[
                    Exec['upgrade bullseye'],
                    ],
      }
    }


    exec { 'delete mxcp':
      command   => "/bin/bash -c '$directory/delete_mxcp.sh >> $directory/logs/prebookworm 2>&1'",
      logoutput => true,
      require   =>[
                  Exec['upgrade bullseye'],
                  ],
    }

    exec { 'upgrade bookworm':
      command   => "/bin/bash -c '$directory/upgrade_bookworm.sh >> $directory/logs/prebookworm 2>&1'",
      logoutput => true,
      timeout   => 10800,
      require   =>[
                  Exec['upgrade bullseye'],
                  ],
    } ->
    exec { 'iptables apache drop after bookworm upgrade':
      command   => "/bin/bash -c '$directory/iptables_apache_drop.sh >> $directory/logs/prebookworm 2>&1'",
      logoutput => true,
    } ->
    exec { 'restart postfix':
      command   => '/usr/sbin/service postfix restart',
      logoutput => true,
      timeout   => 300,
    } ->    
    package { 'systemd-resolved':
      ensure    => purged,
    } ->
    exec { 'fix resolv.conf':
      command   => "/bin/bash -c 'echo nameserver 1.1.1.1 > /etc/resolv.conf'",
      logoutput => true,
    } ->
    exec { 'update source puppet':
      command   => "/bin/bash -c '$directory/update_source_puppet.sh >> $directory/logs/prebookworm 2>&1'",
      logoutput => true,
    } ->
    exec { 'update postgresql 15':
      command   => "/bin/bash -c '$directory/update_postgresql_15.sh >> $directory/logs/prebookworm 2>&1'",
      logoutput => true,
      timeout   => 7200,
    }

    #posbookworm script
    file {"/etc/init.d/posbookworm":
      owner   => 'root',
      group   => 'root',
      mode    => '0700',
      content => template("prebookworm/posbookworm_init"),
    } ->
    file {'/etc/systemd/system/posbookworm.service.d':
      ensure   => directory,
    } ->
    file {'/etc/systemd/system/posbookworm.service.d/deps.conf':
      content => template("prebookworm/posbookworm_init_deps"),
    } ->
    exec { 'activate posbookworm init':
      command   => "/bin/bash -c 'update-rc.d posbookworm defaults 99'",
      logoutput => true,
      require   =>[
                  Exec['update postgresql 15'],
                  ],
    }


    #enable ipv6
    /*
    exec { 'sysctl net.ipv6.conf.all.disable_ipv6 0':
      command     => 'sysctl net.ipv6.conf.all.disable_ipv6=0',
      path        => ['/usr/sbin','/sbin'],
      logoutput   => true,
      require     =>[
                    Exec['update postgresql 15'],
                    ],
    } ->
    exec { 'sysctl net.ipv6.conf.all.forwarding 1':
      command     => 'sysctl net.ipv6.conf.all.forwarding=1',
      path        => ['/usr/sbin','/sbin'],
      logoutput   => true,
    } ->
    file_line{'sysctl.conf net.ipv6.conf.all.disable_ipv6 0':
      ensure => present,
      path   => '/etc/sysctl.conf',
      line   => 'net.ipv6.conf.all.disable_ipv6 = 0',
      match  => '^net.ipv6.conf.all.disable_ipv6.*$',
    } ->
    file_line{'sysctl.conf net.ipv6.conf.all.forwarding 1':
      ensure => present,
      path   => '/etc/sysctl.conf',
      line   => 'net.ipv6.conf.all.forwarding = 1',
      match  => '^net.ipv6.conf.all.forwarding.*$',
    }
    if $facts['mongodb_enabled']{
      ini_setting { 'mongo ipv6 true':
        ensure            => present,
        section           => 'net',
        setting           => 'ipv6',
        value             => 'true',
        path              => '/etc/mongod.conf',
        section_prefix    => '',
        section_suffix    => ':',
        indent_char       => " ",
        indent_width      => 2,
        key_val_separator => ':',
        require           =>[
                            Exec['update postgresql 15'],
                            ],
      }
    }
    exec { 'ipv6 enabled admin notificaction':
      command     => "echo -e ' ' | mail -s 'IPV6 enabled in ${hostname}' ${email}",
      path        => ['/usr/bin','/bin'],
      logoutput   => true,
      require     =>[
                    Exec['update postgresql 15'],
                    ],
    } ->
    exec { 'set ipv6 enabled in ldap':
      command     => '/etc/maadix/scripts/setldapdnattribute.sh ou=ipv6,ou=conf,ou=cpanel,dc=example,dc=tld status enabled',
      path        => ['/usr/bin','/bin'],
      logoutput   => true,
    }
    */

    exec { 'delete persistent iptables rules':
      command   => '/bin/rm /etc/iptables/*',
      onlyif    => 'ls -l /etc/iptables/* | grep rules',
      path      => ['/usr/bin','/usr/sbin','/bin','/sbin'],
    }

    exec { 'system background start':
      command   => "/bin/bash -c '/etc/maadix/scripts/system_background_start.sh >> $directory/logs/prebookworm 2>&1'",
      logoutput => true,
      timeout   => 300,
    }

    exec { 'send report':
      command   => "/bin/bash -c '$directory/send_prebookworm_report.sh'",
    }

    exec { 'disable setreadycpanel':
      command   => '/bin/systemctl disable setreadycpanel',
      require   =>[
                  Exec['update postgresql 15'],
                  ],
    } ->
    exec { 'send prebookworm notify':
      command   => "/bin/bash -c '$directory/send_prebookworm_notify.sh  && sleep 120'",
    }


    #reboot the server unless $disablereboot==true
    if $disablereboot {

      notify { 'reboot server disabled': }

    } else {

      exec { 'reboot server':
          command   => "/bin/bash -c '/lib/molly-guard/shutdown -r now' &",
          logoutput => true,
          require   =>[
                      Exec['upgrade bookworm'],
                      Exec['update postgresql 15'],
                      ],
      }

    }
 
  }

}
