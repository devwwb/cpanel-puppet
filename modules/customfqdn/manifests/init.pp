class customfqdn (
  $enabled = str2bool("$::customfqdn"),
) {

  validate_bool($enabled)

  if $enabled {
     
    file_line{'change fqdn':
      ensure => present,
      path   => '/etc/hosts',
      line   => "${::ipaddress} ${::hostname}.${::fqdn_domain} ${::hostname}",
      match  => ".*${::hostname}.${::fqdn_domain_old}.*${::hostname}.*$",
    }

  }

}
