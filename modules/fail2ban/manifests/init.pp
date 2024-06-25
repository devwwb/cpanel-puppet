class fail2ban (
  Boolean $enabled = str2bool($facts['fail2ban']),
) {

  if $enabled {

    $jails = ['dovecot', 'mxcp', 'apache-auth', 'sshd', 'postfix-sasl']
    $fail2ban_ips = $facts['fail2ban_ips']
    $fail2ban_ips.each |$fail2ban_ip| {
      $jails.each |$jail| {
        exec { "unlock ip $fail2ban_ip from $jail jail":
          command     => "/usr/bin/fail2ban-client set $jail unbanip $fail2ban_ip",
          logoutput   => true,
          #if ip doesn't exists is ok exit code 255
          returns     => [0,255],
        }
      }
    }
  }

}
