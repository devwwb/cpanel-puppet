class posstretch (
  $enabled = str2bool("$::posstretch"),
) {

  validate_bool($enabled)

  if $enabled {

    #define scripts
    $scripts = ['delete_jessie_kernels.sh','update_docker.sh','update_facts_classifier.sh','activate_groups.sh','restore_cpanel_cron.sh','iptables_apache_accept.sh']
    $scripts.each |String $script| {
      file {"/etc/maadix/stretch/${script}":
        owner   => 'root',
        group   => 'root',
        mode    => '0700',
        content => template("posstretch/${script}"),
      }
    }

    exec { 'iptables apache drop':
      command   => "/bin/bash -c '/etc/maadix/stretch/iptables_apache_drop.sh'",
      logoutput => true,
    }

    exec { 'delete_jessie_kernels.sh':
      command   => "/bin/bash -c '/etc/maadix/stretch/delete_jessie_kernels.sh'",
      logoutput => true,
    }

    if ($::docker_group){
      exec { 'update docker':
        command   => "/bin/bash -c '/etc/maadix/stretch/update_docker.sh'",
        logoutput => true,
      }

      exec { 'delete old aufs docker images':
        command   => "/bin/bash -c 'docker image prune -a'",
        logoutput => true,
      }

    }

    exec { 'delete old vhosts':
      command   => "/bin/bash -c 'rm -r /etc/apache2/ldap-enabled'",
      onlyif    => '/usr/bin/test -e /etc/apache2/ldap-enabled',
      logoutput => true,
    }

    exec { 'update facts classifier':
      command   => "/bin/bash -c '/etc/maadix/stretch/update_facts_classifier.sh'",
      logoutput => true,
    }

    exec { 'run puppet to apply stretch catalog':
      command   => '/usr/local/bin/puppet agent --test',
      logoutput => true,
      # --test option implies --detailed-exitcodes. and Exitcode of 2 means that The run succeeded, and some resources were changed
      returns   => 2,
    }

    if ($::discourse_group){
      exec { 'rebuild discourse':
        command   => "/bin/bash -c 'sudo /var/discourse/launcher rebuild app'",
        logoutput => true,
        require   =>[
                    Exec['run puppet to apply stretch catalog'],
                    ],
      }

    }

    exec { 'activate groups':
      command   => "/bin/bash -c '/etc/maadix/stretch/activate_groups.sh'",
      logoutput => true,
      require   =>[
                  Exec['run puppet to apply stretch catalog'],
                  ],
    }

    exec { 'run puppet after groups reactivating':
      command   => '/usr/local/bin/puppet agent --test',
      logoutput => true,
      # --test option implies --detailed-exitcodes. and Exitcode of 2 means that The run succeeded, and some resources were changed
      returns   => 2,
      require   =>[
                  Exec['run puppet to apply stretch catalog'],
                  ],
    }

    exec { 'restore cpanel cron':
      command   => "/bin/bash -c '/etc/maadix/stretch/restore_cpanel_cron.sh'",
      logoutput => true,
      require   =>[
                  Exec['run puppet after groups reactivating'],
                  ],
    }

    exec { 'iptables apache accept':
      command   => "/bin/bash -c '/etc/maadix/stretch/iptables_apache_accept.sh'",
      logoutput => true,
      require   =>[
                  Exec['run puppet after groups reactivating'],
                  ],
    }


  }

}
