require 'yaml'

##facter with domains whose webroots must be purged from trash (status=purge)

#to debug, use STDERR and run 'puppet facts --debug | grep -A 20 trash_purge_webroots' in the agent

Facter.add(:trash_purge_webroots) do

  setcode do
    #build hash with domains webroots that need to be purged
    webrootstopurge = {}
    #get all domains to purge from trash
    domains=Facter::Util::Resolution.exec('ldapsearch -H ldapi:// -Y EXTERNAL -LLL -s one -b "ou=domains,ou=trash,dc=example,dc=tld" "(&(objectClass=applicationProcess)(status=purge))" | grep cn: | sed "s|.*: \(.*\)|\1|"')
    if not domains.nil?
      domains.each_line do |domain|
       trashname = Facter::Util::Resolution.exec('ldapsearch -H ldapi:// -Y EXTERNAL -LLL -s base -b "cn=' + domain.strip + ',ou=domains,ou=trash,dc=example,dc=tld" "(&(objectClass=applicationProcess)(status=purge))" | grep cn: | sed "s|.*: \(.*\)|\1|"')
       webrootstopurge[domain.strip] = {:uid => domain.strip ,:trashname => trashname.strip}
      end
    end
    webrootstopurge
  end

end
