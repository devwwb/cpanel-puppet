define domains::orphandomains(
  $domain	= undef,
  $cn           = undef,
  $trashname    = undef,
  $webroot      = undef,
  $purgecerts   = undef,
) {


  #move deleted domain webroot to trash
  exec {"mv $cn home to trash":
    command     => "/bin/mv $webroot /home/.trash/domains/$trashname",
    require     => File['/home/.trash/domains/'],
    onlyif      => "/usr/bin/test -e $webroot",
  } ->
  #move deleted onion domain to trash
  exec {"mv $cn onion to trash":
    command     => "/bin/mv /var/lib/tor/hiddenservices/$domain /home/.trash/onions/$trashname",
    require     => File['/home/.trash/onions/'],
    onlyif      => "/usr/bin/test -e /var/lib/tor/hiddenservices/$domain",
  } ->

  #assign nobody permissions to deleted domain webroot
  file {"/home/.trash/domains/$trashname":
    ensure      => directory,
    owner       => 'nobody',
    group       => 'nogroup',
    recurse     => true,
  } ->
  #assign nobody permissions to deleted onion
  #assign nobody permissions to deleted onion
  exec {"owner recursive of onions $trashname":
    command      => "chown -R nobody:nogroup /home/.trash/onions/$trashname",
    path         => ['/usr/bin', '/usr/sbin', '/bin'],
    onlyif       => "/usr/bin/test -e /home/.trash/onions/$trashname",
  } ->

  #purge acls
  posix_acl { "/home/.trash/domains/$trashname":
    action     => 'purge',
    permission => [
          "user::rwx",
          "group::rwx",
          "mask::rwx",
          "other::---",
          "user:nobody:rwx",
          "group:nogroup:rwx",
          "default:user::rwx",
          "default:group::rwx",
          "default:mask::rwx",
          "default:other::---",
          "default:user:nobody:rwx",
          "default:group:nogroup:rwx",
    ],
    provider   => posixacl,
    recursive  => true,
  }

  #set deleted domain as moved to trash: status=intrash
  ldapdn{"set $cn status=intrash":
    dn                  => "cn=$cn,ou=domains,ou=trash,dc=example,dc=tld",
    attributes          => ["status: intrash"],
    unique_attributes   => ["status"],
    ensure              => present

  }

  if $purgecerts{
    #remove certs
    unless File["/etc/letsencrypt/live/$domain"]{
      file {"/etc/letsencrypt/live/$domain":
        ensure  => absent,
        recurse => true,
        force   => true,
      }
    }
    unless File["/etc/letsencrypt/archive/$domain"]{
      file {"/etc/letsencrypt/archive/$domain":
        ensure  => absent,
        recurse => true,
        force   => true,
      }
    }
    unless File["/etc/letsencrypt/renewal/$domain"]{
      file {"/etc/letsencrypt/renewal/$domain.conf":
        ensure  => absent,
      }
    }
  }

}
