define domains::orphanhomes(
  $uid		= undef,
  $home		= undef,
  $trashname	= undef,  
) {


  #move deleted user home to trash
  exec {"mv $uid home to trash":
    command	=> "/bin/mv $home /home/.trash/users/$trashname",
    require	=> File['/home/.trash/users/'],
    onlyif	=> "/usr/bin/test -e $home",
  } ->

  #assign nobody permissions to deleted user home
  file {"/home/.trash/users/$trashname":
    ensure	=> directory,
    owner	=> 'nobody',
    group	=> 'nogroup',
    recurse	=> true,
  } ->

  #set deleted user home as moved to trash: status=intrash
  ldapdn{"set $uid status=intrash":
    dn			=> "uid=$uid,ou=users,ou=trash,dc=example,dc=tld",
    attributes		=> ["status: intrash"],
    unique_attributes	=> ["status"],
    ensure		=> present
    
  }

}

