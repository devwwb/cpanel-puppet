class cleanapt (
  Boolean $enabled = str2bool("$::cleanapt"),
) {

  if $enabled {

    #clean downloaded packages
    exec { 'clean apt':
      command => '/usr/bin/apt-get clean',
    }

  }

}
