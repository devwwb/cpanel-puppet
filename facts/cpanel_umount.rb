require 'yaml'

##facter with list of mountpoints to remove: deleted domains or domains that have changed webmaster

#to debug, use STDERR and run 'puppet facts --debug | grep -A 20 cpanel_umount' in the agent

Facter.add(:cpanel_umount) do

  setcode do
    #get existent mountpoints
    system_mounts = {}
    Facter.value(:mountpoints).each do |mount, value|
      #if is an sftuser mountpoint, get domain and user
      if mount.include? 'sftpusers'
        split = mount.split('/')
        system_mounts[split[4]] = split[3]
      end
    end
    #build hash with domain/user pairs that are not in ldap (cpanel_vhosts facter)
    umounts = {}
    system_mounts.each do |mount, value|
      #if domain doesn't exist in cpanel_vhosts add to umount always, else check if webmaster has changed
      if Facter.value(:cpanel_vhosts).key? (mount.strip)
        if not (Facter.value(:cpanel_vhosts)[mount.strip][:domain] == mount.strip and Facter.value(:cpanel_vhosts)[mount.strip][:webmaster] == value.strip)
          umounts[mount.strip] = {:domain => mount.strip, :webmaster => value.strip}
        end
      else
        umounts[mount.strip] = {:domain => mount.strip, :webmaster => value.strip}
      end
    end
    umounts
  end

end
