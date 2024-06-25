class customfqdn (
  Boolean $enabled = str2bool($facts['customfqdn']),
) {

  if $enabled {

    if $facts['fqdn_domain_old'] and $facts['fqdn_domain'] {
      file_line{'change fqdn':
        ensure => present,
        path   => '/etc/hosts',
        line   => "${facts['public_ip']} ${facts['networking']['hostname']}.${facts['fqdn_domain']} ${facts['networking']['hostname']}",
        match  => ".*${facts['networking']['hostname']}.${facts['fqdn_domain_old']}.*${facts['networking']['hostname']}.*$",
      }

      exec{'change fqdn notify by mail':
        command => "/bin/echo 'El host ${facts['networking']['hostname']}.${facts['fqdn_domain_old']} solicita cambio a nuevo fqdn ${facts['networking']['hostname']}.${facts['fqdn_domain']}' | /usr/bin/mail -s 'Maadix: Cambio FQDN en ${facts['networking']['hostname']}' admin@maadix.org",
      }

    }

  }

}
