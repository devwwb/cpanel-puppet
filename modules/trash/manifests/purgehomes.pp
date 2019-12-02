define trash::purgehomes(
  $uid		= undef,
  $trashname	= undef,  
) {


  #move deleted user home to trash
  exec {"purge $uid home with name $trashname from trash":
    command	=> "/bin/rm -r /home/.trash/users/$trashname",
    onlyif	=> "/usr/bin/test -e /home/.trash/users/$trashname",
  } ->

  #delete ldap entry for this user in ldap
  exec {"purge $uid from ldap/trash/users":
    command	=> "/usr/bin/ldapdelete -H ldapi:// -Y EXTERNAL 'cn=$uid,ou=users,ou=trash,dc=example,dc=tld'",
  }

}
