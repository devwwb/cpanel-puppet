define domains::pools(
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
  $acl_enabled          = undef,
  $acl_apply            = undef,
  $mail                 = undef,
  $onion                = undef,
) {

  if $pool != 'www' {

    #create user
    user { $pool:
      ensure        => 'present',
      managehome    => false,
      #system false, to avoid conflicts with os_hardening
      system        => false,
      #os_hardening/manifests/minimize_access.pp params
      shell         => '/usr/sbin/nologin',
      password      => '*',
      password_max_age => '200000',
      notify        => Exec["add group $pool to www-data user"],
    }

    #add user www-data to group fpmX
    exec { "add group $pool to www-data user":
      command       => "/usr/sbin/usermod -a -G $pool www-data",
      refreshonly   => true,
    }

    #create fpm pool
    exec { "add new php pool $pool":
      command       => "/usr/bin/cp /etc/php/${facts['php_version']}/fpm/pool.d/fpm1.conf /etc/php/${facts['php_version']}/fpm/pool.d/${pool}.conf && /usr/bin/sed -i -e 's/fpm1/${pool}/g' /etc/php/${facts['php_version']}/fpm/pool.d/${pool}.conf",
      unless        => "/usr/bin/test -s /etc/php/${facts['php_version']}/fpm/pool.d/${pool}.conf",
      notify        => Exec["reload php fpm after adding new $pool"],
    }

    #restart php
    exec { "reload php fpm after adding new $pool":
      command       => "/usr/sbin/service php${facts['php_version']}-fpm restart",
      refreshonly   => true,
    }

  }
}

