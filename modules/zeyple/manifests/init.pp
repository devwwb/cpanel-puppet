class zeyple (
  $enabled = str2bool("$::zeyple"),
) {

  validate_bool($enabled)

  if $enabled {

    file {'/etc/maadix/scripts/zeyple_keys_sync.sh':
      owner   => 'root',
      group   => 'root',
      mode    => '0700',
      content => template('zeyple/zeyple_keys_sync.sh'),
    } ->
    exec { "sync zeyple keyring with ldap keys":
      command     => '/etc/maadix/scripts/zeyple_keys_sync.sh',
      logoutput   => true,
    }

  }

}
