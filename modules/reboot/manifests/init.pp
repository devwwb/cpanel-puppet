class reboot (
  $enabled = str2bool("$::reboot"),
) {

  validate_bool($enabled)

  if $enabled {
    exec { 'reboot':
      command => "/sbin/reboot",
    }

  }

}

