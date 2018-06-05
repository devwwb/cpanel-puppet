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
    }

  }

}
