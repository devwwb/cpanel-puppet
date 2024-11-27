define trash::purgeonions(
  $uid		= undef,
  $trashname	= undef,  
) {


  #purge deleted onions files/folder from trash
  exec {"purge $uid backup with name $trashname from trash":
    command	=> "/bin/rm -r /home/.trash/onions/$trashname",
    onlyif	=> "/usr/bin/test -e /home/.trash/onions/$trashname",
  } ->

  #delete ldap entry for this item in ldap
  exec {"purge $uid from ldap/trash/onions":
    command	=> "/usr/bin/ldapdelete -H ldapi:// -Y EXTERNAL 'cn=$uid,ou=onions,ou=trash,dc=example,dc=tld'",
  }

}
