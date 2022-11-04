define trash::purgemails(
  $uid		= undef,
  $trashname	= undef,  
) {


  #purge deleted mails from trash
  exec {"purge $uid mail with name $trashname from trash":
    command	=> "/bin/rm -r /home/.trash/mails/$trashname",
    onlyif	=> "/usr/bin/test -e /home/.trash/mails/$trashname",
  } ->

  #delete ldap entry for this user in ldap
  exec {"purge $uid from ldap/trash/mails":
    command	=> "/usr/bin/ldapdelete -H ldapi:// -Y EXTERNAL 'cn=$uid,ou=mails,ou=trash,dc=example,dc=tld'",
  }

}
