class reboot (
  $enabled = str2bool("$::reboot"),
) {

  validate_bool($enabled)

  if $enabled {
    #set module reboot to ready
    ldapdn{'set ou=reboot,ou=cpanel,dc=example,dc=tld status=ready':
      dn                  => 'ou=reboot,ou=cpanel,dc=example,dc=tld',
      attributes          => ["status: ready"],
      unique_attributes   => ["status"],
      ensure              => present
    }

    exec { 'reboot':
      command => "/sbin/reboot",
    }

  }

}
