require 'yaml'

##list of borg archive to mount

#to debug, use STDERR and run 'puppet facts --debug | grep -A 20 borg_mount' in the agent

Facter.add(:borg_mount) do
  setcode do
    mounts = []
    Facter::Util::Resolution.exec('ldapsearch -H ldapi:// -Y EXTERNAL -LLL -s one -b "ou=borgbackup,ou=cpanel,dc=example,dc=tld" "(status=mount)" | grep cn: | sed "s|.*: \(.*\)|\1|"').each_line do |mount|
      mounts.push(mount.strip)
    end
    mounts
  end
end
