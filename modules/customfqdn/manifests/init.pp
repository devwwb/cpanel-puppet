class customfqdn (
  $enabled = str2bool("$::customfqdn"),
) {

  validate_bool($enabled)

  if $enabled {

    if defined('$::fqdn_domain_old') and defined('$::fqdn_domain'){
      file_line{'change fqdn':
        ensure => present,
        path   => '/etc/hosts',
        line   => "${::ipaddress} ${::hostname}.${::fqdn_domain} ${::hostname}",
        match  => ".*${::hostname}.${::fqdn_domain_old}.*${::hostname}.*$",
      }

      exec{'change fqdn notify by mail':
        command => "/bin/echo 'El host ${::hostname}.${::fqdn_domain_old} solicita cambio a nuevo fqdn ${::hostname}.${::fqdn_domain}' | /usr/bin/mail -s 'Maadix: Cambio FQDN en ${::hostname}' admin@maadix.org",
      }

    }

  }

}
