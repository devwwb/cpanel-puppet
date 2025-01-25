class ipv6 (
  Boolean $enabled = str2bool($facts['ipv6']),
  String $fqdn     = $facts['networking']['fqdn'],
) {

  if $enabled {

    if $facts['ipv6_enabled']{

      exec { 'sysctl net.ipv6.conf.all.disable_ipv6 0':
        command     => 'sysctl net.ipv6.conf.all.disable_ipv6=0',
        path        => ['/usr/sbin','/sbin'],
        logoutput   => true,
      }

      exec { 'sysctl net.ipv6.conf.all.forwarding 1':
        command     => 'sysctl net.ipv6.conf.all.forwarding=1',
        path        => ['/usr/sbin','/sbin'],
        logoutput   => true,
      }

      file_line{'sysctl.conf net.ipv6.conf.all.disable_ipv6 0':
        ensure => present,
        path   => '/etc/sysctl.conf',
        line   => 'net.ipv6.conf.all.disable_ipv6 = 0',
        match  => '^net.ipv6.conf.all.disable_ipv6.*$',
      }

      file_line{'sysctl.conf net.ipv6.conf.all.forwarding 1':
        ensure => present,
        path   => '/etc/sysctl.conf',
        line   => 'net.ipv6.conf.all.forwarding = 1',
        match  => '^net.ipv6.conf.all.forwarding.*$',
      }

      #mongo
      if $facts['mongodb_enabled']{
        ini_setting { 'mongo ipv6 true':
          ensure            => present,
          section           => 'net',
          setting           => 'ipv6',
          value             => 'true',
          path              => '/etc/mongod.conf',
          section_prefix    => '',
          section_suffix    => ':',
          indent_char       => " ",
          indent_width      => 2,
          key_val_separator => ':',
        }
      }

      #openvpn
      if $facts['openvpn_enabled']{
        file_line{'openvpn server-ipv6':
          ensure  => present,
          path    => "/etc/openvpn/${fqdn}.conf",
          line    => 'server-ipv6 fd42:42:42:42::/112',
          match   => '^server-ipv6.*$',
        }
      }

    } else {

      exec { 'sysctl net.ipv6.conf.all.disable_ipv6 1':
        command     => 'sysctl net.ipv6.conf.all.disable_ipv6=1',
        path        => ['/usr/sbin','/sbin'],
        logoutput   => true,
      }

      exec { 'sysctl net.ipv6.conf.all.forwarding 0':
        command     => 'sysctl net.ipv6.conf.all.forwarding=0',
        path        => ['/usr/sbin','/sbin'],
        logoutput   => true,
      }

      file_line{'sysctl.conf net.ipv6.conf.all.disable_ipv6 1':
        ensure => present,
        path   => '/etc/sysctl.conf',
        line   => 'net.ipv6.conf.all.disable_ipv6 = 1',
        match  => '^net.ipv6.conf.all.disable_ipv6.*$',
      }

      file_line{'sysctl.conf net.ipv6.conf.all.forwarding 0':
        ensure => present,
        path   => '/etc/sysctl.conf',
        line   => 'net.ipv6.conf.all.forwarding = 0',
        match  => '^net.ipv6.conf.all.forwarding.*$',
      }

      #mongo
      if $facts['mongodb_enabled']{
        ini_setting { 'mongo ipv6 false':
          ensure            => present,
          section           => 'net',
          setting           => 'ipv6',
          value             => 'false',
          path              => '/etc/mongod.conf',
          section_prefix    => '',
          section_suffix    => ':',
          indent_char       => " ",
          indent_width      => 2,
          key_val_separator => ':',
        }
      }

      #openvpn
      if $facts['openvpn_enabled']{
        file_line{'openvpn server-ipv6':
          ensure  => absent,
          path    => "/etc/openvpn/${fqdn}.conf",
          match   => '^server-ipv6.*$',
          match_for_absence => true,
        }
      }

    }
  }

}
