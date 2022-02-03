class borgkey (
  $enabled = str2bool("$::borgkey"),
) {

  validate_bool($enabled)

  if $enabled {

    #script to export borgbackup key to ldap
    file {"/etc/maadix/scripts/borgkey.sh":
      owner   => 'root',
      group   => 'root',
      mode    => '0700',
      content => template("borgkey/borgkey.sh"),
    }

    #leave a copy of key in ldap for some minutes and delete later
    exec { 'expose borg keyfile in ldap for some minutes':
      command => "/bin/bash -c '/etc/maadix/scripts/borgkey.sh' &",
    }

  }

}
