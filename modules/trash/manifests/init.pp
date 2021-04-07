class trash (
  $enabled   = str2bool("$::trash"),
) {

  validate_bool($enabled)

  if $enabled {

    ## tasks in order ##

    #purge users home from trash
    create_resources(trash::purgehomes, $::trash_purge_homes)

    #purge domains webroot from trash
    create_resources(trash::purgewebroots, $::trash_purge_webroots)

    #purge backup files from trash
    create_resources(trash::purgebackups, $::trash_purge_backups)

  }

}
