class luks (
  $enabled = str2bool("$::luks"),
) {

  validate_bool($enabled)

  if $enabled {

    file {'/etc/maadix/scripts/luks.sh':
      owner   => 'root',
      group   => 'root',
      mode    => '0700',
      content => template('luks/luks.sh'),
    } ->
    exec { "update luks keys":
      command => "/bin/bash -c '/etc/maadix/scripts/luks.sh' &",
      logoutput   => true,
    }

  }

}
