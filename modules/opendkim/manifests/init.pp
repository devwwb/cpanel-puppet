class opendkim (
  Boolean $enabled = str2bool("$::opendkim"),
) {

  if $enabled {

    #service
    service { 'opendkim':
      ensure  => running,
      enable  => true,
    }

    #truncate KeyTable and SigningTable
    file { '/etc/opendkim/KeyTable':
      owner   => 'opendkim',
      group   => 'opendkim',
      mode    => '640',
      content => '',
    }

    file { '/etc/opendkim/SigningTable':
      owner   => 'opendkim',
      group   => 'opendkim',
      mode    => '640',
      content => '',
    }

  }

}
