require 'yaml'

##facter with backup folders and files that must be purged from trash (status=purge)

#to debug, use STDERR and run 'puppet facts --debug | grep -A 20 trash_purge_backups' in the agent

Facter.add(:trash_purge_backups) do

  setcode do
    #build hash with backups that need to be purged
    backupstopurge = {}
    #get all backups  to purge from trash
    backups=Facter::Util::Resolution.exec('ldapsearch -H ldapi:// -Y EXTERNAL -LLL -s one -b "ou=backups,ou=trash,dc=example,dc=tld" "(&(objectClass=applicationProcess)(status=purge))" | grep cn: | sed "s|.*: \(.*\)|\1|"')
    if not backups.nil?
      backups.each_line do |backup|
       trashname = Facter::Util::Resolution.exec('ldapsearch -H ldapi:// -Y EXTERNAL -LLL -s base -b "cn=' + backup.strip + ',ou=backups,ou=trash,dc=example,dc=tld" "(&(objectClass=applicationProcess)(status=purge))" | grep cn: | sed "s|.*: \(.*\)|\1|"')
       backupstopurge[backup.strip] = {:uid => backup.strip.gsub("+", "\\\\+") ,:trashname => trashname.strip}
      end
    end
    backupstopurge
  end

end
