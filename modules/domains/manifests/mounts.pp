define domains::mounts(
  $domain		= undef,
  $webmaster		= undef,
  $webmaster_type	= undef,
  $www                  = undef,
  $regenerate		= undef,
  $dns			= undef,
) {

  #only mount domains assigned to webmaster of type sftp
  if $webmaster_type == 'sftp' {
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

