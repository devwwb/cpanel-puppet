class domains (
  Boolean $enabled   = str2bool($facts['domains']),
  String $vhost_dir  = '/etc/apache2/ldap-enabled',
  String $nginx_dir  = '/etc/nginx/ldap-enabled',
  String $nginx_tor  = '/etc/nginx/onion-enabled',
  Boolean $nginx     = $facts['nginx_enabled'],
  Boolean $tor       = $facts['tor_enabled'],
) {

  if $enabled {

    ## tasks in order ##

    #ensure /home/.trash folder
    file {'/home/.trash':
      ensure  => directory,
    }->
    file {'/home/.trash/users':
      ensure  => directory,
    }->
    file {'/home/.trash/domains':
      ensure  => directory,
    }->
    file {'/home/.trash/mails':
      ensure  => directory,
    }

    #purge ldap-enabled vhost dir
    file { $vhost_dir:
      ensure  => directory,
      recurse => true,
      purge   => true,
      notify  => Exec['reload apache'],
    }

    #wp cms setup script
    file {"/etc/maadix/scripts/wp_setup.sh":
      content   => template('domains/wp_setup.sh'),
      mode      => '700',
    }

    #ensure sftpuser home folders to mount domains
    create_resources(domains::sftpusershome, $facts['cpanel_users'])

    #umount domains (deleted or assigned to a different user)
    create_resources(domains::umount, $facts['cpanel_umount'])

    #create vhosts (vhost, webroot, letsencrypt cert)
    create_resources(domains::vhosts, $facts['cpanel_vhosts'])

    #setup cms
    create_resources(domains::cms, $facts['cpanel_vhosts'])

    #delete vhosts non-ssl for those domains without certs
    create_resources(domains::cleanfailedvhosts, $facts['cpanel_vhosts'])

    #mount domains
    create_resources(domains::mounts, $facts['cpanel_vhosts'])

    #clean orphan domains (certs and permissions)
    create_resources(domains::orphandomains, $facts['cpanel_orphan_vhosts'])

    #clean orphan mails
    create_resources(domains::orphanmails, $facts['cpanel_orphan_mails'])

    #move orphan users homes to trash
    create_resources(domains::orphanhomes, $facts['cpanel_orphan_homes'])

    ## utilities ##

    #reload apache
    exec {'reload apache':
      command     => 'service apache2 reload',
      path	  => ['/usr/bin', '/usr/sbin', '/bin'],
      refreshonly => true,
    }

    #reload apache end
    exec {'reload apache end':
      command     => 'service apache2 reload',
      path	  => ['/usr/bin', '/usr/sbin', '/bin'],
      refreshonly => true,
    }
 
    if $nginx {
      #purge ldap-enabled vhost dir
      file { $nginx_dir:
        ensure      => directory,
        recurse     => true,
        purge       => true,
        notify      => Exec['reload nginx'],
      }

      #reload nginx
      exec {'reload nginx':
        command     => 'service nginx restart',
        path        => ['/usr/bin', '/usr/sbin', '/bin'],
        refreshonly => true,
        before      => Exec['reload apache end'],

      }

      #haproxy maps
      exec { 'generate haproxy hosts.maps':
        command     => '/etc/maadix/scripts/haproxy_hosts.maps.sh',
      } ->
      #reload haproxy
      exec {'reload haproxy':
        command     => 'service haproxy reload',
        path        => ['/usr/bin', '/usr/sbin', '/bin'],
      }

    }

    if $tor {
      #purge onion-enabled vhost dir
      file { $nginx_tor:
        ensure      => directory,
        recurse     => true,
        purge       => true,
        notify      => Exec['reload nginx'],
      }

      # tor hidden services conf
      concat { '/etc/tor/torhiddenservices':
        mode        => '0444',
        owner       => 'root',
        group       => 'root',
        notify      => [
                       Exec['reload tor'],
                       Exec['mxcp onions'],
                       ],
      }

      #reload tor
      exec {'reload tor':
        command     => 'service tor reload',
        path        => ['/usr/bin', '/usr/sbin', '/bin'],
        refreshonly => true,
        before      => Exec['reload apache end'],

      }

      #expose onions to mxcp
      exec {'mxcp onions':
        command     => '/usr/local/bin/facter -p maadix_tor_hidden_services > /usr/share/mxcp/onions',
        refreshonly => true,
        require     => Exec['reload tor'],
        path        => ['/usr/bin', '/usr/sbin', '/bin'],
      }

    }

    #clean php sessions
    Exec {'clean php sessions':
      command     => 'find /var/lib/php/sessions -type f -delete',
      path        => ['/usr/bin', '/bin'],
      require     => Exec['reload apache end'],
      refreshonly => true,
    }

  }

}
