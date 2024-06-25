class samhaincheck (
  Boolean $enabled = str2bool($facts['samhaincheck']),
) {

  if $enabled {

    #check samhain
    exec { 'check samhain':
      command => '/usr/sbin/samhain -t check',
    }

  }

}
