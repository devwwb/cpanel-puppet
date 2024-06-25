class cleanapt (
  Boolean $enabled = str2bool($facts['cleanapt']),
) {

  if $enabled {

    #clean downloaded packages
    exec { 'clean apt':
      command => '/usr/bin/apt-get clean',
    }

  }

}
