class tally (
  Boolean $enabled = str2bool($facts['tally']),
) {

  if $enabled {

    $tally_users = $facts['tally_users']
    $tally_users.each |$tally_user| {
      #unlock users
      if $facts['os']['distro']['codename']=='buster'{
        exec { "unlock user $tally_user":
          command     => "pam_tally2 --user $tally_user --reset",
          path        => ['/usr/sbin','/sbin'],
          logoutput   => true,
          #if user doesn't exists is ok exit code 1
          returns     => [0,1],
        }
      }
      if $facts['os']['distro']['codename']=='bullseye'{
        exec { "unlock user $tally_user":
          command     => "faillock --user $tally_user --reset",
          path        => ['/usr/sbin','/sbin'],
          logoutput   => true,
          #if user doesn't exists is ok exit code 1
          returns     => [0,1],
        }
      }
    }

  }

}
