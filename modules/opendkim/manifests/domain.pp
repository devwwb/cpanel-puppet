define opendkim::domain (
  $enabled = str2bool("$::opendkim"),
  $domain        = $name,
  $selector      = 'default',
  $pathkeys      = '/etc/opendkim/keys',
  $keytable      = 'KeyTable',
  $signing_table = 'SigningTable',
  $pathconf      = '/etc/opendkim',
) {

  validate_bool($enabled)

  if $enabled {

    # $pathConf and $pathKeys must be without trailing '/'.
    # For example, '/etc/opendkim/keys'

    Exec { path => [ '/bin/', '/sbin/' , '/usr/bin/', '/usr/sbin/' ] }

    # Create directory for domain
    file { "${pathkeys}/${domain}":
        ensure  => directory,
        owner   => 'opendkim',
        group   => 'opendkim',
        mode    => '0755',
        notify  => Service['opendkim'],
    }

    # Generate dkim-keys
    exec { "opendkim-genkey -D ${pathkeys}/${domain}/ -d ${domain} -s ${selector}":
        unless  => "/usr/bin/test -f ${pathkeys}/${domain}/${selector}.private && /usr/bin/test -f ${pathkeys}/${domain}/${selector}.txt",
        user    => 'opendkim',
        notify  => Service['opendkim'],
        require => [ 
                    File["${pathkeys}/${domain}"], 
                   ],
    }

    # Change perms of public key files
    file { "${pathkeys}/${domain}/${selector}.txt":
        owner   => 'opendkim',
        group   => 'opendkim',
        mode    => '0755',
    }

    # Add line into KeyTable
    file_line { "${pathconf}/${keytable}_${domain}":
        path    => "${pathconf}/${keytable}",
        line    => "${selector}._domainkey.${domain} ${domain}:${selector}:${pathkeys}/${domain}/${selector}.private",
        notify  => Service['opendkim'],
    }

    # Add line into SigningTable
    file_line { "${pathconf}/${signing_table}_${domain}":
        path    => "${pathconf}/${signing_table}",
        line    => "*@${domain} ${selector}._domainkey.${domain}",
        notify  => Service['opendkim'],
    }

  }

}
