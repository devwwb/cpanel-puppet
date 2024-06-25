class borgbackup (
  Boolean $enabled = str2bool($facts['borgbackup']),
) {

  if $enabled {

    $borg_enabled  = $facts['borg_params']['borg_enabled']
    $user          = $facts['borg_params']['user']
    $server        = $facts['borg_params']['server']
    $port          = $facts['borg_params']['port']
    $sudouser      = $facts['borg_params']['sudouser']

    #checks
    if $borg_enabled==false or $user=='' or $server==''{
      fail('Borgbackup module interrupted: some params are missing')
    }

    #debug
    notify{"Params: enable: $borg_enabled, user: $user, server: $server, port: $port, sudouser: $sudouser, hostname: ${facts['networking']['hostname']}": }

    #if service is active
    if $borg_enabled {

      #sudo user home
      exec {"mkhomedir_helper $sudouser 0077 /etc/skel":
        creates      => "/home/$sudouser",
        path         => ['/usr/bin', '/usr/sbin',],
      }

      #main directory
      file {'borg root folder for mounts':
        ensure       => directory,
        path         => "/home/$sudouser/${facts['networking']['hostname']}-backups",
        owner        => "$sudouser",
        mode         => '700',
      }

      #mount
      $facts['borg_mount'].each |$archive| {
        #mount directory
        file {"borg mount dir for $archive":
          ensure     => directory,
          path       => "/home/$sudouser/${facts['networking']['hostname']}-backups/$archive",
          owner      => "$sudouser",
          mode       => '700',
        }->
        exec { "mount borg archive $archive":
          command    => "/usr/bin/borg mount --rsh 'ssh -i /root/.ssh/id_rsa_borgbackup' -o allow_other,ignore_permissions,ro --strip-components 0 ssh://$user@$server:$port/./backup::$archive /home/$sudouser/${facts['networking']['hostname']}-backups/$archive",
        }->
        exec { "delete borg ldap object of $archive":
          command    => "/usr/bin/ldapdelete -H ldapi:// -Y EXTERNAL 'cn=$archive,ou=borgbackup,ou=cpanel,dc=example,dc=tld'",
        }
      }

      #umount
      $facts['borg_umount'].each |$archive| {
        exec { "umount borg archive $archive":
          command    => "/usr/bin/borg umount /home/$sudouser/${facts['networking']['hostname']}-backups/$archive",
        }->
        exec { "delete borg ldap object of $archive":
          command    => "/usr/bin/ldapdelete -H ldapi:// -Y EXTERNAL 'cn=$archive,ou=borgbackup,ou=cpanel,dc=example,dc=tld'",
        }->
        #delete mount directory
        file {"delete borg mount dir for $archive":
          ensure     => absent,
          path       => "/home/$sudouser/${facts['networking']['hostname']}-backups/$archive",
          force      => true,        
        }
      }

    }

  }

}
