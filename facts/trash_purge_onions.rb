require 'yaml'

##facter with backup folders and files that must be purged from trash (status=purge)

#to debug, use STDERR and run 'puppet facts --debug | grep -A 20 trash_purge_backups' in the agent

Facter.add(:trash_purge_onions) do

  setcode do
    #build hash with backups that need to be purged
    itemstopurge = {}
    #get all onionss backups  to purge from trash
    onions=Facter::Util::Resolution.exec('ldapsearch -H ldapi:// -Y EXTERNAL -LLL -s one -b "ou=onions,ou=trash,dc=example,dc=tld" "(&(objectClass=applicationProcess)(status=purge))" | grep cn: | sed "s|.*: \(.*\)|\1|"')
    if not onions.nil?
      onions.each_line do |onion|
       trashname = Facter::Util::Resolution.exec('ldapsearch -H ldapi:// -Y EXTERNAL -LLL -s base -b "cn=' + onion.strip + ',ou=onions,ou=trash,dc=example,dc=tld" "(&(objectClass=applicationProcess)(status=purge))" | grep cn: | sed "s|.*: \(.*\)|\1|"')
       itemstopurge[onion.strip] = {:uid => onion.strip.gsub("+", "\\\\+") ,:trashname => trashname.strip}
      end
    end
    itemstopurge
  end

end
