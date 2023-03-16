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

  #assign nobody permissions to deleted domain webroot
  file {"/home/.trash/domains/$trashname":
    ensure      => directory,
    owner       => 'nobody',
    group       => 'nogroup',
    recurse     => true,
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

}
