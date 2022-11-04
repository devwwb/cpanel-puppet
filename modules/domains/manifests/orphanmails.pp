define domains::orphanmails(
  $mail         = undef,
  $cn           = undef,
  $trashname    = undef,
  $mailhome     = undef,
) {

  #move deleted mailhome to trash
  exec {"mv $cn home to trash":
    command     => "/bin/mv $mailhome /home/.trash/mails/$trashname",
    require     => File['/home/.trash/mails/'],
    onlyif      => "/usr/bin/test -e $mailhome",
  } ->

  #assign nobody permissions to deleted domain mailhome
  file {"/home/.trash/mails/$trashname":
    ensure      => directory,
    owner       => 'nobody',
    group       => 'nogroup',
    recurse     => true,
  } ->

  #set deleted domain as moved to trash: status=intrash
  ldapdn{"set $cn status=intrash":
    dn                  => "cn=$cn,ou=mails,ou=trash,dc=example,dc=tld",
    attributes          => ["status: intrash"],
    unique_attributes   => ["status"],
    ensure              => present

  }

}
