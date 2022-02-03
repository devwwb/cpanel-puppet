require 'yaml'

##list of borg archive to umount

#to debug, use STDERR and run 'puppet facts --debug | grep -A 20 borg_umount' in the agent

Facter.add(:borg_umount) do
  setcode do
    umounts = []
    Facter::Util::Resolution.exec('ldapsearch -H ldapi:// -Y EXTERNAL -LLL -s one -b "ou=borgbackup,ou=cpanel,dc=example,dc=tld" "(status=umount)" | grep cn: | sed "s|.*: \(.*\)|\1|"').each_line do |umount|
      umounts.push(umount.strip)
    end
    umounts
  end
end
