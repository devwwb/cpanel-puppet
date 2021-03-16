class mysql (
  $enabled = str2bool("$::mysql"),
) {

  validate_bool($enabled)

  if $enabled {

    #script to set mysql passwd on activation
    file {"/etc/maadix/scripts/mysqlpass_activate.sh":
      owner   => 'root',
      group   => 'root',
      mode    => '0700',
      content => template("mysql/mysqlpass_activate.sh"),
    } -> 
    exec { 'change mysql pass':
      command   => "/bin/bash -c '/etc/maadix/scripts/mysqlpass_activate.sh'",
    }

  }

}
