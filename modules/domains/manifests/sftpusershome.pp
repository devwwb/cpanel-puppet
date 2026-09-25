define domains::sftpusershome(
  $uid		= undef,
  $type		= undef,
) {

  #create sftpuser home
  if $type == 'sftp'{
    file {"/home/jailedUsers/$uid":
      ensure      => directory,
    } ->
    file {"/home/jailedUsers/$uid/$uid":
      ensure      => directory,
      owner       => "$uid",
      mode        => "700",
    }
  }

}
