class borgbackup (
  $enabled = str2bool("$::borgbackup"),
) {

  validate_bool($enabled)

  if $enabled {

    #params
    $borg_enabled = $::borg_params['borg_enabled']
    $user         = $::borg_params['user']
    $server       = $::borg_params['server']
    $port         = $::borg_params['port']
    $sudouser     = $::borg_params['sudouser']

    #validate params
    validate_bool($borg_enabled)

    #checks
    if $borg_enabled==undef or $user==undef or $server==undef or $port==undef or $sudouser==undef{
      fail('Borgbackup module interrupted: some params are missing')
    }

    #debug
    notify{"Params: enable: $borg_enabled, user: $user, server: $server, port: $port, sudouser: $sudouser, hostname: $::hostname": }

    #if service is active
    if $borg_enabled {

      #main directory
      file {'borg root folder for mounts':
        ensure       => directory,
        path         => "/home/$sudouser/$::hostname-backups",
        owner        => "$sudouser",
        mode         => '700',
      }

      #mount
      $::borg_mount.each |$archive| {
        #mount directory
        file {"borg mount dir for $archive":
          ensure     => directory,
          path       => "/home/$sudouser/$::hostname-backups/$archive",
          owner      => "$sudouser",
          mode       => '700',
        }
        exec { "mount borg archive $archive":
          command    => "/usr/bin/borg mount --rsh 'ssh -i /root/.ssh/id_rsa_borgbackup' -o allow_other,ignore_permissions,ro --strip-components 1 ssh://$user@$server:$port/./backup::$archive /home/$sudouser/$::hostname-backups/$archive",
        }
        exec { "delete borg ldap object of $archive":
          command    => "/usr/bin/ldapdelete -H ldapi:// -Y EXTERNAL 'cn=$archive,ou=borgbackup,ou=cpanel,dc=example,dc=tld'",
        }
      }

      #umount
      $::borg_umount.each |$archive| {
        exec { "umount borg archive $archive":
          command    => "/usr/bin/borg umount /home/$sudouser/$::hostname-backups/$archive",
        }
        exec { "delete borg ldap object of $archive":
          command    => "/usr/bin/ldapdelete -H ldapi:// -Y EXTERNAL 'cn=$archive,ou=borgbackup,ou=cpanel,dc=example,dc=tld'",
        }
        #delete mount directory
        file {"delete borg mount dir for $archive":
          ensure     => absent,
          path       => "/home/$sudouser/$::hostname-backups/$archive",
          force      => true,        
        }
      }

    }

  }

}
