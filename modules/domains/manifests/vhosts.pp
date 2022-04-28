define domains::vhosts(
  $domain		= undef,
  $webmaster		= undef,
  $webmaster_type       = undef,
  $www			= undef,
  $regenerate           = undef,
  $dns			= undef,
  $oldwebmaster		= undef,
  $pool			= undef,
  $oldpool		= undef,
) {

  #create vhost and cert only if domain has DNS resolution
  if $dns {

    #vhost non-ssl
    file {"/etc/apache2/ldap-enabled/$domain.conf":
      content	=> template('domains/vhost.erb'),
      notify	=> Exec['reload apache'],
    }

    #webroot folder group
    case $pool {
      'www':  {
         $group = 'www-data'
      }
      default:  {
         $group = $pool
      }
    }
    case $oldpool {
      'www':  {
         $oldgroup = 'www-data'
      }
      default:  {
         $oldgroup = $pool
      }
    }

    #change perms/owner of domain webroot only if webmaster or pool changes for existent domains
    if (($webmaster != $oldwebmaster) and ($oldwebmaster != '')) or (($pool != $oldpool) and ($oldpool != '')){
      #webroot folder + owner/group and permissions
      if ($webmaster != $oldwebmaster) and ($oldwebmaster != '') {
        file {"/var/www/html/$domain":
          ensure	=> directory,
          owner		=> $webmaster,
          group		=> $group,
          mode		=> '2770',
          notify	=> Exec["owner recursive of $domain",
                                'reload apache'
                               ],
        }
      }
      if ($pool != $oldpool) and ($oldpool != '') {
        file {"/var/www/html/$domain":
          ensure	=> directory,
          owner		=> $webmaster,
          group		=> $group,
          mode		=> '2770',
          notify	=> Exec["group recursive of $domain",
                                'reload apache'
                               ],
        }
      }
      #when domain is assigned to another webmaster or pool, change owner or group recursive
      #change only files and folders owned by oldwebmaster. If user has change the owner of a file or dir manually, leave it as is
      exec {"owner recursive of $domain":
        command	   => "find /var/www/html/$domain -user $oldwebmaster -exec chown $webmaster {} +",
        refreshonly  => true,
        path	   => ['/usr/bin', '/usr/sbin', '/bin'],
      }
      #change only files and folders owned by group oldpool. If user has change the group of a file or dir manually, leave it as is
      exec {"group recursive of $domain":
        command	   => "find /var/www/html/$domain -group $oldgroup -exec chgrp $oldgroup {} +",
        refreshonly  => true,
        path	   => ['/usr/bin', '/usr/sbin', '/bin'],
      } 
    #perms/owner of domain webroot for new domains
    } elsif $oldwebmaster == '' {
      #webroot folder + owner/group and permissions
      file {"/var/www/html/$domain":
        ensure	=> directory,
        owner	=> $webmaster,
        group	=> $group,
        mode	=> '2770',
        notify	=> Exec['reload apache'],
      }
    } else {
      file {"/var/www/html/$domain":
        ensure	=> directory,
      }
    }

    #letsencrypt certs
    if $www {
      exec {"SSL for $domain":
        command	  => "certbot -d $domain -d www.$domain --agree-tos --email $::adminmail --webroot --webroot-path /var/www/html/$domain --non-interactive --text --rsa-key-size 4096  certonly",
        path      => ['/usr/bin', '/usr/sbin', '/bin'],
        creates	  => "/etc/letsencrypt/live/$domain/cert.pem",
        require   => [
                     File["/var/www/html/$domain"],
                     Exec['reload apache'],
                     ],
      }
    } else {
      exec {"SSL for $domain":
        command	  => "certbot -d $domain --agree-tos --email $::adminmail --webroot --webroot-path /var/www/html/$domain --non-interactive --text --rsa-key-size 4096  certonly",
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
        command	=> "certbot -d $domain -d www.$domain --agree-tos --expand --email $::adminmail --webroot --webroot-path /var/www/html/$domain --non-interactive --text --rsa-key-size 4096  certonly",
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
      mode	=> '2770',
    }
  
  }


}

