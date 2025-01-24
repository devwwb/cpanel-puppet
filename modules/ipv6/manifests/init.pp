class ipv6 (
  Boolean $enabled = str2bool($facts['ipv6']),
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

    }
  }

}
