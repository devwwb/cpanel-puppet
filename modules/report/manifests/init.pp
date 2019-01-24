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
    $scripts = ['dist_upgrade_packages.sh','vm_packages_report.sh','vm_docker_report.sh','send_report.sh']
    $scripts.each |String $script| {
      file {"$directory/${script}":
        owner   => 'root',
        group   => 'root',
        mode    => '0700',
        content => template("report/${script}"),
      }
    }

    
    exec { "dist upgrade packages":
      command   => "/bin/bash -c '$directory/dist_upgrade_packages.sh > $directory/logs/dist_upgrade_packages.sh.log 2>&1'",
      logoutput => true,
    }

    exec { 'vm packages report':
      command   => "/bin/bash -c '$directory/vm_packages_report.sh > $directory/logs/vm_packages_report.sh.log 2>&1'",
      logoutput => true,
    }


    if ($::docker_group){
      exec { 'vm docker report':
        command   => "/bin/bash -c '$directory/vm_docker_report.sh > $directory/logs/vm_docker_report.sh.log 2>&1'",
        logoutput => true,
      }
    }

    exec { 'send report':
      command   => "/bin/bash -c '$directory/send_report.sh'",
      logoutput => true,
    }


  }

}
