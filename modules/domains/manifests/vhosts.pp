define domains::vhosts(
  $cms                  = undef,
  $cms_type             = undef,
  $active		= undef,
  $webroot		= undef,
  $domain		= undef,
  $webmaster		= undef,
  $webmaster_type       = undef,
  $www			= undef,
  $regenerate           = undef,
  $dns			= undef,
  $oldwebmaster		= undef,
  $pool			= undef,
  $oldpool		= undef,
  $tree			= undef,
) {

  #vars
  $path = $tree[-1]

  #create vhost and cert only if domain has DNS resolution and if domain is active
  if $dns and $active {

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
         $oldgroup = $oldpool
      }
    }

    #change perms/owner of domain webroot only if webmaster or pool changes for existent domains
    if (($webmaster != $oldwebmaster) and ($oldwebmaster != '')) or (($pool != $oldpool) and ($oldpool != '')){
      #webroot folder + owner/group and permissions
      if (($webmaster != $oldwebmaster) and ($oldwebmaster != '')) and (($pool != $oldpool) and ($oldpool != '')){
        file { $tree:
          ensure	=> directory,
          owner		=> $webmaster,
          group		=> $group,
          mode		=> '2770',
          notify	=> Exec["owner recursive of $domain",
                                "group recursive of $domain",
                                'reload apache'
                               ],
        }
      } elsif ($webmaster != $oldwebmaster) and ($oldwebmaster != '') {
        file { $tree:
          ensure	=> directory,
          owner		=> $webmaster,
          group		=> $group,
          mode		=> '2770',
          notify	=> Exec["owner recursive of $domain",
                                'reload apache'
                               ],
        }
      } elsif ($pool != $oldpool) and ($oldpool != '') {
        file { $tree:
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
        command	   => "find /var/www/html/$domain -group $oldgroup -exec chgrp $group {} +",
        refreshonly  => true,
        path	   => ['/usr/bin', '/usr/sbin', '/bin'],
        notify     => Exec['clean php sessions'],
      } 
    #perms/owner of domain webroot for new domains
    } elsif $oldwebmaster == '' {
      #webroot folder + owner/group and permissions
      file { $tree:
        ensure	=> directory,
        owner	=> $webmaster,
        group	=> $group,
        mode	=> '2770',
        notify	=> Exec['reload apache'],
      }
    } else {
      file { $tree:
        ensure	=> directory,
      }
    }

    #letsencrypt certs
    if $www {
      exec {"SSL for $domain":
        command	  => "certbot -d $domain -d www.$domain --agree-tos --email $::adminmail --webroot --webroot-path $path --non-interactive --text --rsa-key-size 4096  certonly",
        path      => ['/usr/bin', '/usr/sbin', '/bin'],
        creates	  => "/etc/letsencrypt/live/$domain/cert.pem",
        require   => [
                     File[$path],
                     Exec['reload apache'],
                     ],
      }
    } else {
      exec {"SSL for $domain":
        command	  => "certbot -d $domain --agree-tos --email $::adminmail --webroot --webroot-path $path --non-interactive --text --rsa-key-size 4096  certonly",
        path      => ['/usr/bin', '/usr/sbin', '/bin'],
        creates	  => "/etc/letsencrypt/live/$domain/cert.pem",
        require   => [
                     File[$path],
                     Exec['reload apache'],
                     ],
      }
    }

    if $regenerate {
      exec {"SSL expand for $domain":
        command	=> "certbot -d $domain -d www.$domain --agree-tos --expand --email $::adminmail --webroot --webroot-path $path --non-interactive --text --rsa-key-size 4096  certonly",
        path      => ['/usr/bin', '/usr/sbin', '/bin'],
        require   => [
                     File[$path],
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

    #create webroot if enabled
    if $webroot {
      #webroot folder + owner/group and permissions
      file { $tree:
        ensure	=> directory,
        owner	=> $webmaster,
        group	=> 'www-data',
        mode	=> '2770',
      }
    }
  
  }

  #delete certs for inactive domains
  unless $active {
    #remove certs
    file {"/etc/letsencrypt/live/$domain":
      ensure    => absent,
      recurse   => true,
      force     => true,
    }
    file {"/etc/letsencrypt/archive/$domain":
      ensure    => absent,
      recurse   => true,
      force     => true,
    }
    file {"/etc/letsencrypt/renewal/$domain.conf":
      ensure    => absent,
    }
  }


}

