class trash (
  Boolean $enabled   = str2bool($facts['trash']),
) {

  if $enabled {

    ## tasks in order ##

    #purge users home from trash
    create_resources(trash::purgehomes, $facts['trash_purge_homes'])

    #purge domains webroot from trash
    create_resources(trash::purgewebroots, $facts['trash_purge_webroots'])

    #purge mails from trash
    create_resources(trash::purgemails, $facts['trash_purge_mails'])

    #purge backup files from trash
    create_resources(trash::purgebackups, $facts['trash_purge_backups'])

    #purge onion keys from trash
    create_resources(trash::purgeonions, $facts['trash_purge_onions'])


  }

}
