define domains::orphandomains(
  $domain	= undef,
) {

  #assign nobody permissions to deleted domain
  file {"/var/www/html/$domain":
    ensure	=> directory,
    owner	=> 'nobody',
    group	=> 'nogroup',
    recurse	=> true,
  }

  #remove certs
  file {"/etc/letsencrypt/live/$domain":
    ensure	=> absent,
    recurse	=> true,
    force	=> true,
  }
  file {"/etc/letsencrypt/archive/$domain":
    ensure	=> absent,
    recurse	=> true,
    force	=> true,
  }
  file {"/etc/letsencrypt/renewal/$domain.conf":
    ensure	=> absent,
  }

}

