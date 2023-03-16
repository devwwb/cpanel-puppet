define domains::mounts(
  $cms                  = undef,
  $cms_type             = undef,
  $active		= undef,
  $webroot		= undef,
  $domain		= undef,
  $webmaster		= undef,
  $webmaster_type	= undef,
  $www                  = undef,
  $regenerate		= undef,
  $dns			= undef,
  $oldwebmaster		= undef,
  $pool			= undef,
  $oldpool              = undef,
  $tree			= undef,
  $acl_enabled          = undef,
  $acl_apply            = undef,
) {

  #only mount domains with webroot enabled, assigned to webmaster of type sftp
  if $webmaster_type == 'sftp' and $webroot {
    #ensure sftpuser home domain folder to mount domain
    file {"/home/sftpusers/$webmaster/$domain":
      owner	=> $webmaster,
      ensure	=> directory,
    }
    
    #mount domain in sftpuser home
    mount {"/home/sftpusers/$webmaster/$domain":
      ensure  => mounted, 
      device  => "/var/www/html/$domain",
      fstype  => 'none', 
      options => 'rw,bind', 
    }
  }

}

