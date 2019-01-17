class prestretch (
  $enabled = str2bool("$::prestretch"),
) {

  validate_bool($enabled)

  if $enabled {

    ##stretch scripts directory
    file { '/etc/maadix/stretch':
      ensure => directory,
      mode   => '0700',
    }

    #define scripts
    $scripts = ['deactivate_groups.sh', 'delete_cpanel_cron.sh', 'update_mongodb_34.sh', 'update_postgresql_96.sh', 'delete_mailman_venv_34.sh', 'delete_global_nodejs.sh', 'delete_onlyoffice_image.sh', 'upgrade_jessie.sh', 'update_source_debian.sh', 'update_source_docker.sh', 'update_source_lool.sh', 'update_source_mongodb.sh', 'delete_jessie_sources.sh', 'delete_jessie_packages.sh', 'delete_phpmyadmin.sh', 'upgrade_stretch.sh', 'update_mongodb_36.sh', 'delete_obsolete_packages.sh', 'update_onecontext.sh', 'update_puppet.sh', 'update_extlinux.sh', 'posstretch_init.sh']
    $scripts.each |String $script| {
      file {"/etc/maadix/stretch/${script}":
        owner   => 'root',
        group   => 'root',
        mode    => '0700',
        content => template("prestretch/${script}"),
      }
    }

/*

    exec { 'deactivate groups':
      command   => "/bin/bash -c '/etc/maadix/stretch/deactivate_groups.sh'",
      logoutput => true,
    }

    exec { 'run puppet to deactivate groups':
      command   => '/usr/local/bin/puppet agent --test',
      logoutput => true,
      # --test option implies --detailed-exitcodes. and Exitcode of 2 means that The run succeeded, and some resources were changed
      returns   => 2,
    }

    exec { 'delete cpanel cron':
      command   => "/bin/bash -c '/etc/maadix/stretch/delete_cpanel_cron.sh'",
      logoutput => true,
    }

    if ($::mongodb_group){
      exec { 'update mongodb 3.4':
        command   => "/bin/bash -c '/etc/maadix/stretch/update_mongodb_34.sh'",
        logoutput => true,
      }
    }

    if ($::postgresql_group){
      exec { 'update postgresql 9.6':
        command   => "/bin/bash -c '/etc/maadix/stretch/update_postgresql_96.sh'",
        logoutput => true,
      }
    }

    if ($::mailman_venv3_group){
      exec { 'delete mailman venv 3.4':
        command   => "/bin/bash -c '/etc/maadix/stretch/delete_mailman_venv_34.sh'",
        logoutput => true,
      }
    }

    if ($::nodejs_group){
      exec { 'delete global nodejs':
        command   => "/bin/bash -c '/etc/maadix/stretch/delete_global_nodejs.sh'",
        logoutput => true,
      }
    }

    if ($::onlyoffice_group){
      exec { 'delete onlyoffice image':
        command   => "/bin/bash -c '/etc/maadix/stretch/delete_onlyoffice_image.sh'",
        logoutput => true,
      }
    }

    exec { 'upgrade jessie':
      command   => "/bin/bash -c '/etc/maadix/stretch/upgrade_jessie.sh'",
      logoutput => true,
    }

    
    exec { 'update source debian':
      command   => "/bin/bash -c '/etc/maadix/stretch/update_source_debian.sh'",
      logoutput => true,
    }

    if ($::mongodb_group){
      exec { 'update source mongodb':
        command   => "/bin/bash -c '/etc/maadix/stretch/update_source_mongodb.sh'",
        logoutput => true,
      }
    }

    if ($::lool_group){
      exec { 'update source lool':
        command   => "/bin/bash -c '/etc/maadix/stretch/update_source_lool.sh'",
        logoutput => true,
      }
    }

    if ($::docker_group){
      exec { 'update source docker':
        command   => "/bin/bash -c '/etc/maadix/stretch/update_source_docker.sh'",
        logoutput => true,
      }
    }

    exec { 'delete jessie sources':
      command   => "/bin/bash -c '/etc/maadix/stretch/delete_jessie_sources.sh'",
      logoutput => true,
    }

    exec { 'delete jessie packages':
      command   => "/bin/bash -c '/etc/maadix/stretch/delete_jessie_packages.sh'",
      logoutput => true,
    }

    if ($::phpmyadmin_group){
      exec { 'delete phpmyadmin':
        command   => "/bin/bash -c '/etc/maadix/stretch/delete_phpmyadmin.sh'",
        logoutput => true,
      }
    }

    exec { 'upgrade stretch':
      command   => "/bin/bash -c '/etc/maadix/stretch/upgrade_stretch.sh'",
      logoutput => true,
      timeout   => 1800,
    }

    exec { 'restart postfix':
      command   => '/usr/sbin/service postfix restart',
      logoutput => true,
    }

    if ($::mongodb_group){
      exec { 'update mongodb 3.6':
        command   => "/bin/bash -c '/etc/maadix/stretch/update_mongodb_36.sh'",
        logoutput => true,
      }
    }

    exec { 'delete obsolete packages':
      command   => "/bin/bash -c '/etc/maadix/stretch/delete_obsolete_packages.sh'",
      logoutput => true,
    }

    exec { 'update onecontext':
      command   => "/bin/bash -c '/etc/maadix/stretch/update_onecontext.sh'",
      logoutput => true,
    }

    exec { 'update puppet':
      command   => "/bin/bash -c '/etc/maadix/stretch/update_puppet.sh'",
      logoutput => true,
    }

    exec { 'update extlinux':
      command   => "/bin/bash -c '/etc/maadix/stretch/update_extlinux.sh'",
      logoutput => true,
    }
*/

    exec { 'posstretch init':
      command   => "/bin/bash -c '/etc/maadix/stretch/posstretch_init.sh'",
      logoutput => true,
    }



  }

}
