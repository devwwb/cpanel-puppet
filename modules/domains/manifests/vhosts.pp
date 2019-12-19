define domains::vhosts(
  $domain		= undef,
  $webmaster		= undef,
  $webmaster_type       = undef,
  $www			= undef,
  $regenerate           = undef,
  $dns			= undef,
) {

  #create vhost and cert only if domain has DNS resolution
  if $dns {

    #vhost non-ssl
    file {"/etc/apache2/ldap-enabled/$domain.conf":
      content	=> template('domains/vhost.erb'),
      notify	=> Exec['reload apache'],
    } ->
    #webroot folder + owner/group and permissions
    file {"/var/www/html/$domain":
      ensure	=> directory,
      owner	=> $webmaster,
      group	=> 'www-data',
      mode	=> '2775',
      notify	=> Exec['reload apache'],
    } ~>
    #when domain is assigned to another webmaster, change owner recursive
    exec {"owner/group recursive of $domain":
      command	   => "chown -R $webmaster:www-data /var/www/html/$domain",
      refreshonly  => true,
      path	   => ['/usr/bin', '/usr/sbin', '/bin'],
    }

    #letsencrypt certs
    if $www {
      exec {"SSL for $domain":
        command	  => "certbot -d $domain -d www.$domain --staging --agree-tos --email $::adminmail --webroot --webroot-path /var/www/html/$domain --non-interactive --text --rsa-key-size 4096  certonly",
        path      => ['/usr/bin', '/usr/sbin', '/bin'],
        creates	  => "/etc/letsencrypt/live/$domain/cert.pem",
        require   => [
                     File["/var/www/html/$domain"],
                     Exec['reload apache'],
                     ],
      }
    } else {
      exec {"SSL for $domain":
        command	  => "certbot -d $domain --agree-tos --staging --email $::adminmail --webroot --webroot-path /var/www/html/$domain --non-interactive --text --rsa-key-size 4096  certonly",
        path      => ['/usr/bin', '/usr/sbin', '/bin'],
        creates	  => "/etc/letsencrypt/live/$domain/cert.pem",
        require   => [
                     File["/var/www/html/$domain"],
                     Exec['reload apache'],
                     ],
      }
    }

    if $regenerate {
      exec {"SSL expand for $domain":
        command	=> "certbot -d $domain -d www.$domain --staging --agree-tos --expand --email $::adminmail --webroot --webroot-path /var/www/html/$domain --non-interactive --text --rsa-key-size 4096  certonly",
        path      => ['/usr/bin', '/usr/sbin', '/bin'],
        require   => [
                     File["/var/www/html/$domain"],
                     Exec['reload apache'],
                     ],
      }
    }

    #vhost ssl
    file {"/etc/apache2/ldap-enabled/$domain-ssl.conf":
      content	=> template('domains/vhost-ssl.erb'),
      require	=> Exec["SSL for $domain"],
      notify	=> Exec['reload apache end'],
    }

  } else {

    #webroot folder + owner/group and permissions
    file {"/var/www/html/$domain":
      ensure	=> directory,
      owner	=> $webmaster,
      group	=> 'www-data',
      mode	=> '2775',
    }
  
  }


}

