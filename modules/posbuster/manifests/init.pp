class posbuster (
  $enabled = str2bool("$::posbuster"),
  $directory = '/etc/maadix/buster',
) {

  validate_bool($enabled)

  if $enabled {

    #define scripts
    $scripts = ['delete_obsolete_packages.sh',
                'upgrade_easyrsa_openvpn.sh',
                'update_docker.sh',
                'activate_groups.sh',
                'deactivate_groups.sh',
                'iptables_apache_accept.sh',
                'set_ready_api.sh',
                'send_posbuster_report.sh',
                'send_posbuster_notify.sh']
    $scripts.each |String $script| {
      file {"$directory/${script}":
        owner   => 'root',
        group   => 'root',
        mode    => '0700',
        content => template("posbuster/${script}"),
      }
    }

    #we are in buster, set vm status in api to ready
    exec { 'set_ready_api':
      command   => "/bin/bash -c '$directory/set_ready_api.sh >> $directory/logs/posbuster 2>&1'",
      logoutput => true,
    }

    exec { 'reset posbuster log':
      command   => "/bin/rm $directory/logs/posbuster",
      onlyif    => "/usr/bin/test -f $directory/logs/posbuster",
    } ->
    exec { 'iptables apache drop':
      command   => "/bin/bash -c '$directory/iptables_apache_drop.sh >> $directory/logs/posbuster 2>&1'",
      logoutput => true,
    }

    #mark packages as manually installed to avoid autoremove to purge them later
    exec { 'mark slapd as manually installed':
      command => '/usr/bin/apt-mark manual slapd',
      logoutput => true,
    }

    #clean phamm packages before running puppet
    exec { 'clean phamm':
      command => '/usr/bin/apt-get -y remove --purge phamm-ldap phamm-ldap-amavis phamm-ldap-vacation',
      onlyif    => '/usr/bin/dpkg -l | grep phamm',
      logoutput => true,
    }


    #clean downloaded packages
    exec { 'clean apt':
      command => '/usr/bin/apt-get clean',
    }

    #clean unused images and containers
    if ($::docker_group){
      exec { 'clean docker before apply buster catalog':
        command   => '/usr/bin/docker run --rm --userns host -v /var/run/docker.sock:/var/run/docker.sock -v /etc:/etc -e GRACE_PERIOD_SECONDS=10 spotify/docker-gc',
        logoutput => true,
      }
    }

    if ($::docker_group){
      exec { 'update docker':
        command   => "/bin/bash -c '$directory/update_docker.sh >> $directory/logs/posbuster 2>&1'",
        logoutput => true,
        timeout   => 1800,
      }
    }

    if ($::discourse_group){
      exec { 'rebuild discourse app':
        command   => "/usr/bin/sudo /var/discourse/launcher rebuild app >> $directory/logs/posbuster 2>&1",
        timeout   => 7200,
      }
    }

    #upgrade openvpn
    if ($::openvpn_group){
      exec { 'update easyrsa pki openvpn':
        command   => "/bin/bash -c '$directory/upgrade_easyrsa_openvpn.sh >> $directory/logs/posbuster 2>&1'",
        creates   => "/etc/openvpn/$::fqdn/easy-rsa/openssl-easyrsa.cnf",
        logoutput => true,
        timeout   => 1800,
      }
    }

    exec { 'run puppet to apply buster catalog':
      #run puppet to apply buster catalog without purging certs
      command   => "/usr/local/bin/puppet agent --certname $::hostname.maadix.org --test --skip_tags letsencrypt::certonly >> $directory/logs/posbuster 2>&1",
      logoutput => true,
      # --test option implies --detailed-exitcodes. and Exitcode of 2 means that The run succeeded, and some resources were changed
      returns   => 2,
      timeout   => 7200,
    }

    exec { 'iptables apache accept':
      command   => "/bin/bash -c '$directory/iptables_apache_accept.sh >> $directory/logs/posbuster 2>&1'",
      logoutput => true,
      require   =>[
                  Exec['run puppet to apply buster catalog'],
                  ],
    } ->
    exec { 'activate all groups':
      command   => "/bin/bash -c '$directory/activate_groups.sh >> $directory/logs/posbuster 2>&1'",
      logoutput => true,
    } ->
    exec { 'run puppet after groups reactivating':
      command   => "/usr/local/bin/puppet agent --certname $::hostname.maadix.org --test >> $directory/logs/posbuster 2>&1",
      logoutput => true,
      # --test option implies --detailed-exitcodes. and Exitcode of 2 means that The run succeeded, and some resources were changed
      returns   => 2,
      timeout   => 7200,
    } ->
    exec { 'deactivate deactivated groups':
      command   => "/bin/bash -c '$directory/deactivate_groups.sh >> $directory/logs/posbuster 2>&1'",
      logoutput => true,
    } ->
    exec { 'run puppet after groups deactivating':
      command   => "/usr/local/bin/puppet agent --certname $::hostname.maadix.org --test >> $directory/logs/posbuster 2>&1",
      logoutput => true,
      # --test option implies --detailed-exitcodes. and Exitcode of 2 means that The run succeeded, and some resources were changed
      returns   => 2,
      timeout   => 7200,
    } ->
    exec { 'delete_obsolete_packages.sh':
      command   => "/bin/bash -c '$directory/delete_obsolete_packages.sh >> $directory/logs/posbuster 2>&1'",
      timeout   => 3600,
      logoutput => true,
    } ->
    exec { 'purge jitsi and prosody packages':
      command   => 'apt remove --purge -y jicofo jitsi-meet jitsi-meet-prosody jitsi-meet-web jitsi-meet-web-config jitsi-videobridge2 prosody prosody-modules lua-ldap',
      onlyif    => 'dpkg -l | grep jitsi',
      path      => '/usr/bin:/bin',
    } ->
    exec { 'purge jitsi passwords':
      command   => 'rm /etc/maadix/jicofo && rm /etc/maadix/jicofoauth && rm /etc/maadix/jitsivideobridge',
      onlyif    => 'test -f /etc/maadix/jicofo',
      path      => '/usr/bin:/bin',
    } ->
    exec { 'purge prosody conf':
      command => 'rm -r /etc/prosody',
      onlyif  => 'test -d /etc/prosody',
      path    => '/usr/bin:/bin',
    }->
    exec { 'purge jitsi conf':
      command => 'rm -r /etc/jitsi',
      onlyif  => 'test -d /etc/jitsi',
      path    => '/usr/bin:/bin',
    }->
    exec { 'purge prosody var':
      command => 'rm -r /var/lib/prosody',
      onlyif  => 'test -d /var/lib/prosody',
      path    => '/usr/bin:/bin',
    }->
    exec { 'run puppet after removing obsolete packages':
      command   => "/usr/local/bin/puppet agent --certname $::hostname.maadix.org --test >> $directory/logs/posbuster 2>&1",
      logoutput => true,
      # --test option implies --detailed-exitcodes. and Exitcode of 2 means that The run succeeded, and some resources were changed
      returns   => 2,
      timeout   => 7200,
    } ->
    exec { 'set_ready_api.sh':
      command   => "/bin/bash -c '$directory/set_ready_api.sh >> $directory/logs/posbuster 2>&1'",
      logoutput => true,
    }


    #clean unused images and containers
    if ($::docker_group){
      exec { 'clean docker after apply buster catalog':
        command   => '/usr/bin/docker run --rm --userns host -v /var/run/docker.sock:/var/run/docker.sock -v /etc:/etc -e GRACE_PERIOD_SECONDS=10 spotify/docker-gc',
        logoutput => true,
      }
    }

    exec { 'send cpanel to ready':
      command   => '/etc/init.d/setreadycpanel restart',
    }

    exec { 'disable and remove script posbuster':
      command   => '/usr/sbin/update-rc.d posbuster remove && /bin/rm /etc/init.d/posbuster && /bin/rm -r /etc/systemd/system/posbuster.service.d',
    }

    exec { 'delete persistent iptables rules':
      command   => '/bin/rm /etc/iptables/*',
      onlyif    => 'ls -l /etc/iptables/* | grep rules',
      path      => ['/usr/bin','/usr/sbin','/bin','/sbin'],
    }

    exec { 'send report':
      command   => "/bin/bash -c '$directory/send_posbuster_report.sh'",
    }

    exec { 'send posbuster notify':
      command   => "/bin/bash -c '$directory/send_posbuster_notify.sh'",
      logoutput => true,
      require   =>[
                  Exec['set_ready_api.sh'],
                  ],
    } ->
    exec { 'enable setreadycpanel':
      command   => '/bin/systemctl enable setreadycpanel',
    }


  }

}
