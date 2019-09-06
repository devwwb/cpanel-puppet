class samhainreset (
  $enabled = str2bool("$::samhainreset"),
) {

  validate_bool($enabled)

  if $enabled {

    #reset samhain
    exec { 'reset samhain':
      command => '/usr/sbin/samhain -t update',
    }

  }

}
