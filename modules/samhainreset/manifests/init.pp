class samhainreset (
  Boolean $enabled = str2bool($facts['samhainreset']),
) {

  if $enabled {

    #reset samhain
    exec { 'reset samhain':
      command => '/usr/sbin/samhain -t update',
    }

  }

}
