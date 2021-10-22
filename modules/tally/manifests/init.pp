class tally (
  $enabled = str2bool("$::tally"),
) {

  validate_bool($enabled)

  if $enabled {

    $tally_users = $::tally_users
    $tally_users.each |$tally_user| {
      #unlock users
      exec { "unlock user $tally_user":
        command     => "/usr/sbin/pam_tally2 --user $tally_user --reset",
        logoutput   => true,
        #if user doesn't exists is ok exit code 1
        returns     => [0,1],
      }
    }

  }

}
