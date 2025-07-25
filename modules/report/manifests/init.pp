class report (
  Boolean $enabled   = str2bool($facts['report']),
  String $directory = '/etc/maadix/report',
) {

  if $enabled {

    ##report scripts directory
    file { "$directory":
      ensure => directory,
      mode   => '0700',
    }

    ##log report scripts directory
    file { "$directory/logs":
      ensure => directory,
      mode   => '0700',
    }

    #define scripts
    $scripts = ['luks_info.sh', 'list_groups.sh','list_fqdn_apps.sh','vm_packages_report.sh','vm_docker_report.sh','iptables_report.sh','disk_report.sh','send_report.sh']
    $scripts.each |String $script| {
      file {"$directory/${script}":
        owner   => 'root',
        group   => 'root',
        mode    => '0700',
        content => template("report/${script}"),
      }
    }

    if ($facts['is_luks']){
      exec { 'luks report':
        command   => "/bin/bash -c '$directory/luks_info.sh > $directory/logs/00_disk.log'",
        logoutput => true,
      }
    }

    exec { "disk info":
      command   => "/bin/bash -c 'echo \"## DISK info ######\" > $directory/logs/00_disk.log && lsblk -l >> $directory/logs/00_disk.log'",
      logoutput => true,
    }

    exec { "cpu info":
      command   => "/bin/bash -c 'echo \"## CPU info ######\" > $directory/logs/00_list_cpu.log && cat /proc/cpuinfo | grep \"model name\" >> $directory/logs/00_list_cpu.log'",
      logoutput => true,
    }

    exec { "avx cpu support":
      command   => "/bin/bash -c 'echo \"## CPU avx SUPPORT ######\" >> $directory/logs/00_list_cpu.log && if [ $(grep -c \"avx\" /proc/cpuinfo) -gt 0 ]; then echo \"AVX SUPPORT / OK\" >> $directory/logs/00_list_cpu.log; else echo \"AVX NOT SUPPORTED!\" >> $directory/logs/00_list_cpu.log; fi'",
      logoutput => true,
    }

    exec { "puppet info":
      command   => "/bin/bash -c 'echo \"## Puppet info ######\" > $directory/logs/00_puppet.log && apt-show-versions | grep puppet >> $directory/logs/00_puppet.log'",
      logoutput => true,
    }

    exec { "etc info":
      command   => "/bin/bash -c 'echo \"## ETC info ######\" > $directory/logs/00_www.log && du -sh /etc >> $directory/logs/00_www.log'",
      logoutput => true,
    }

    exec { "ldap database 1 info":
      command   => "/bin/bash -c 'echo \"## Ldap DATABASE Number 1 ######\" >> $directory/logs/00_www.log && cat /etc/ldap/slapd.d/cn\\=config/*olcDatabase*1* | grep olcSuffix >> $directory/logs/00_www.log'",
      logoutput => true,
    }

    exec { "ldap database 2 info":
      command   => "/bin/bash -c 'echo \"## Ldap Database Number 2 ######\" >> $directory/logs/00_www.log && cat /etc/ldap/slapd.d/cn\\=config/*olcDatabase*2* | grep olcSuffix >> $directory/logs/00_www.log'",
      logoutput => true,
      onlyif    => 'test -f /etc/ldap/slapd.d/cn\=config/olcDatabase\=\{2\}mdb.ldif',
      path      => ['/usr/bin','/bin'],
    }

    exec { "php fpm info":
      command   => "/bin/bash -c 'echo \"## PHP fpm ######\" >> $directory/logs/00_www.log && ps aux | grep php-fpm | grep master >> $directory/logs/00_www.log'",
      logoutput => true,
    }

    exec { "sysctl info":
      command   => "/bin/bash -c 'echo \"## Sysctl info ######\" >> $directory/logs/00_www.log && ls -l /etc/sysctl.d/ >> $directory/logs/00_www.log'",
      logoutput => true,
    }

    exec { "grub info":
      command   => "/bin/bash -c 'echo \"## Grub info ######\" >> $directory/logs/00_www.log && cat /etc/default/grub >> $directory/logs/00_www.log'",
      logoutput => true,
    }

    exec { "hosts info":
      command   => "/bin/bash -c 'echo \"## Hosts info ######\" >> $directory/logs/00_www.log && cat /etc/hosts >> $directory/logs/00_www.log'",
      logoutput => true,
    }

    exec { "network info":
      command   => "/bin/bash -c 'echo \"## Network info ######\" >> $directory/logs/00_www.log && ifconfig >> $directory/logs/00_www.log'",
      logoutput => true,
    }

    exec { "network manager info":
      command   => "/bin/bash -c 'echo \"## Network manager info ######\" >> $directory/logs/00_www.log && systemctl status NetworkManager.service >> $directory/logs/00_www.log'",
      returns   => [0,3],
      logoutput => true,
    }

    exec { "network systemd info":
      command   => "/bin/bash -c 'echo \"## Network systemd info ######\" >> $directory/logs/00_www.log && systemctl status systemd-networkd.service >> $directory/logs/00_www.log'",
      returns   => [0,3],
      logoutput => true,
    }

    exec { "redmine info":
      command   => "/bin/bash -c 'echo \"## REDMINE info ######\" >> $directory/logs/00_www.log && apt-show-versions | grep redmine >> $directory/logs/00_www.log'",
      logoutput => true,
      onlyif    => 'apt-show-versions | grep redmine',
      path      => ['/usr/bin','/bin'],
    }

    exec { "moodle data info":
      command   => "/bin/bash -c 'echo \"## MOODLE data info ######\" >> $directory/logs/00_www.log && du -sch /var/www/moodle/* >> $directory/logs/00_www.log'",
      logoutput => true,
      onlyif    => 'test -d /var/www/moodle',
      path      => ['/usr/bin','/bin'],
    }

    exec { "www info":
      command   => "/bin/bash -c 'echo \"## WWW info ######\" >> $directory/logs/00_www.log && du -sch /var/www/* >> $directory/logs/00_www.log && du -sch /var/www/html/* >> $directory/logs/00_www.log'",
      logoutput => true,
    }

    exec { "ddbb mysql info":
      command   => "/bin/bash -c 'echo \"## DDBB mysql info ######\" >> $directory/logs/00_www.log && du -sch /var/lib/mysql/* >> $directory/logs/00_www.log'",
      logoutput => true,
    }

    exec { "ddbb postgresql info":
      command   => "/bin/bash -c 'echo \"## DDBB postgresql info ######\" >> $directory/logs/00_www.log && du -sh /var/lib/postgresql/13/main >> $directory/logs/00_www.log'",
      onlyif    => 'test -f /usr/bin/pg_ctlcluster',
      path      => ['/usr/bin','/usr/sbin','/bin','/sbin'],
      logoutput => true,
    }

    exec { "ddbb mongodb info":
      command   => "/bin/bash -c 'echo \"## DDBB mongodb info ######\" >> $directory/logs/00_www.log && du -sh /var/lib/mongodb >> $directory/logs/00_www.log'",
      onlyif    => 'test -f /usr/bin/mongod',
      path      => ['/usr/bin','/usr/sbin','/bin','/sbin'],
      logoutput => true,
    }

    exec { "crontabs info":
      command   => "/bin/bash -c 'echo \"## CRONTABS info ######\" > $directory/logs/00_zcron.log && for f in /var/spool/cron/crontabs/*; do echo \"USER \$f file\"; cat \$f | grep -v \"#\"; done >> $directory/logs/00_zcron.log'",
      logoutput => true,
    }

    if ($facts['nextcloud_enabled']){
      exec { 'nextcloud cron':
        command   => "/bin/bash -c 'echo \"## NEXTCLOUD cron log ######\" >> $directory/logs/00_zcron.log && sudo -u fpmnextcloud php -f /var/www/nextcloud/nextcloud/cron.php >> $directory/logs/00_zcron.log 2>&1'",
        logoutput => true,
        returns   => [0,255],
      }
    }

    exec { "list services":
      command   => "/bin/bash -c 'echo \"## Services ######\" > $directory/logs/00_list_services.log && service --status-all >> $directory/logs/00_list_services.log'",
      logoutput => true,
    }
    
    exec { "list groups":
      command   => "/bin/bash -c '$directory/list_groups.sh > $directory/logs/01_list_groups.sh.log 2>&1'",
      logoutput => true,
      timeout   => 3600,
    }

    exec { "list fqdn apps":
      command   => "/bin/bash -c '$directory/list_fqdn_apps.sh > $directory/logs/02_list_fqdn_apps.sh.log 2>&1'",
      logoutput => true,
      timeout   => 3600,
    }

    file {"/tmp/${facts['os']['distro']['codename']}_reference":
      content => template("report/${facts['os']['distro']['codename']}_reference"),
    } ->
    exec { 'vm packages report':
      command   => "/bin/bash -c '$directory/vm_packages_report.sh > $directory/logs/03_vm_packages_report.sh.log 2>&1'",
      logoutput => true,
      timeout   => 3600,
    }


    if ($facts['docker_group']){
      exec { 'vm docker report':
        command   => "/bin/bash -c '$directory/vm_docker_report.sh > $directory/logs/04_vm_docker_report.sh.log 2>&1'",
        logoutput => true,
      }
    }

    exec { 'iptables report':
      command   => "/bin/bash -c '$directory/iptables_report.sh > $directory/logs/05_iptables_report.sh.log 2>&1'",
      logoutput => true,
      timeout   => 3600,
    }

    exec { 'disk report':
      command   => "/bin/bash -c '$directory/disk_report.sh > $directory/logs/06_disk_report.sh.log 2>&1'",
      logoutput => true,
    }

    exec { 'send report':
      command   => "/bin/bash -c '$directory/send_report.sh'",
      logoutput => true,
    }


  }

}
