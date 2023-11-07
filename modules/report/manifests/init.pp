class report (
  $enabled   = str2bool("$::report"),
  $directory = '/etc/maadix/report',
) {

  validate_bool($enabled)

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
    $scripts = ['list_groups.sh','list_fqdn_apps.sh','vm_packages_report.sh','vm_docker_report.sh','iptables_report.sh','disk_report.sh','send_report.sh']
    $scripts.each |String $script| {
      file {"$directory/${script}":
        owner   => 'root',
        group   => 'root',
        mode    => '0700',
        content => template("report/${script}"),
      }
    }

    exec { "cpu info":
      command   => "/bin/bash -c 'echo \"## CPU info ######\" > $directory/logs/00_list_cpu.log && cat /proc/cpuinfo | grep \"model name\" >> $directory/logs/00_list_cpu.log'",
      logoutput => true,
    }

    exec { "list services":
      command   => "/bin/bash -c 'service --status-all > $directory/logs/00_list_services.log 2>&1'",
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

    file {"/tmp/${::lsbdistcodename}_reference":
      content => template("report/${::lsbdistcodename}_reference"),
    } ->
    exec { 'vm packages report':
      command   => "/bin/bash -c '$directory/vm_packages_report.sh > $directory/logs/03_vm_packages_report.sh.log 2>&1'",
      logoutput => true,
      timeout   => 3600,
    }


    if ($::docker_group){
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
