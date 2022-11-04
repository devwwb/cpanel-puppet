require 'yaml'

##facter with mails that must be purged from trash (status=purge)

#to debug, use STDERR and run 'puppet facts --debug | grep -A 20 trash_purge_mails' in the agent

Facter.add(:trash_purge_mails) do

  setcode do
    #build hash with mails that need to be purged
    mailstopurge = {}
    #get all mails to purge from trash
    mails=Facter::Util::Resolution.exec('ldapsearch -o ldif-wrap=no -H ldapi:// -Y EXTERNAL -LLL -s one -b "ou=mails,ou=trash,dc=example,dc=tld" "(&(objectClass=applicationProcess)(status=purge))" | grep cn: | sed "s|.*: \(.*\)|\1|"')
    if not mails.nil?
      mails.each_line do |mail|
       trashname = Facter::Util::Resolution.exec('ldapsearch -o ldif-wrap=no -H ldapi:// -Y EXTERNAL -LLL -s base -b "cn=' + mail.strip + ',ou=mails,ou=trash,dc=example,dc=tld" "(&(objectClass=applicationProcess)(status=purge))" | grep cn: | sed "s|.*: \(.*\)|\1|"')
       mailstopurge[mail.strip] = {:uid => mail.strip ,:trashname => trashname.strip}
      end
    end
    mailstopurge
  end

end
