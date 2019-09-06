class samhaincheck (
  $enabled = str2bool("$::samhaincheck"),
) {

  validate_bool($enabled)

  if $enabled {

    #check samhain
    exec { 'check samhain':
      command => '/usr/sbin/samhain -t check',
    }

  }

}
