define domains::sftpusershome(
  $uid		= undef,
  $type		= undef,
) {

  #create sftpuser home
  if $type == 'sftp'{
    file {"/home/sftpusers/$uid":
      ensure      => directory,
    }
  }

}

