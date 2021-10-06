class rkhunter (
  $enabled = str2bool("$::rkhunter"),
) {

  validate_bool($enabled)

  if $enabled {

    #update rkhunter
    exec { 'update rkhunter':
      command     => '/usr/bin/rkhunter --update --propupd',
      logoutput   => true,
      #--update exit codes can be 0,1,2, https://linux.die.net/man/8/rkhunter
      returns     => [0,1,2],
      timeout     => 3600,
    }

  }

}
