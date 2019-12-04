define trash::purgewebroots(
  $uid		= undef,
  $trashname	= undef,  
) {


  #purge deleted domains webroot from trash
  exec {"purge $uid webroot with name $trashname from trash":
    command	=> "/bin/rm -r /home/.trash/domains/$trashname",
    onlyif	=> "/usr/bin/test -e /home/.trash/domains/$trashname",
  } ->

  #delete ldap entry for this user in ldap
  exec {"purge $uid from ldap/trash/domains":
    command	=> "/usr/bin/ldapdelete -H ldapi:// -Y EXTERNAL 'cn=$uid,ou=domains,ou=trash,dc=example,dc=tld'",
  }

}
