class samhaincheck (
  Boolean $enabled = str2bool("$::samhaincheck"),
) {

  if $enabled {

    #check samhain
    exec { 'check samhain':
      command => '/usr/sbin/samhain -t check',
    }

  }

}
