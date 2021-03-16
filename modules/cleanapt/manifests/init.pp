class cleanapt (
  $enabled = str2bool("$::cleanapt"),
) {

  validate_bool($enabled)

  if $enabled {

    #clean downloaded packages
    exec { 'clean apt':
      command => '/usr/bin/apt-get clean',
    }

  }

}
