define domains::cms(
  $cms			= undef,
  $cms_type		= undef,
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
) {


  #vars
  $path = $tree[-1]

  #setup cms only if domain has DNS resolution and if domain is active and webroot if enabled and cms is enabled
  if $dns and $active and $webroot and $cms{

    #webroot folder group
    case $pool {
      'www':  {
         $group = 'www-data'
      }
      default:  {
         $group = $pool
      }
    }

    #cms setup script
    case $cms_type {
      'wordpress':  {
         $setup_script = 'wp_setup.sh'
      }
      default:  {
         $setup_script = ''
      }
    }

    if $cms_type != '' {

      exec {"setup $cms_type of $domain":
        command	   => "/etc/maadix/scripts/$setup_script $domain $webmaster $group $path",
        logoutput  => true,
        path	   => ['/usr/bin', '/usr/sbin', '/bin', '/usr/local/bin'],
      }

    }

  }
}

