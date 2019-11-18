define domains::umount(
  $domain		= undef,
  $webmaster		= undef,
) {

  #umount domain in sftpuser home
  mount {"/home/sftpusers/$webmaster/$domain":
    ensure  => absent,
    device  => "/var/www/html/$domain",
    fstype  => 'none', 
    options => 'rw,bind', 
  }->
  file {"/home/sftpusers/$webmaster/$domain":
    ensure  => absent,
    force   => true,
  }

}

