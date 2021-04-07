define trash::purgebackups(
  $uid		= undef,
  $trashname	= undef,  
) {


  #purge deleted backups files/folder from trash
  exec {"purge $uid backup with name $trashname from trash":
    command	=> "/bin/rm -r /home/.trash/backups/$trashname",
    onlyif	=> "/usr/bin/test -e /home/.trash/backups/$trashname",
  } ->

  #delete ldap entry for this item in ldap
  exec {"purge $uid from ldap/trash/backups":
    command	=> "/usr/bin/ldapdelete -H ldapi:// -Y EXTERNAL 'cn=$uid,ou=backups,ou=trash,dc=example,dc=tld'",
  }

}
