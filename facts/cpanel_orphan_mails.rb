require 'yaml'

##facter with deleted mails

#to debug, use STDERR and run 'puppet facts --debug | grep -A 20 cpanel_orphan_mails' in the agent

Facter.add(:cpanel_orphan_mails) do

  setcode do
    #build hash with mails that are not in ldap anymore
    orphanmails = {}
    #get all mails deleted from ldap from ou=mails,ou=trash
    mails=Facter::Util::Resolution.exec('ldapsearch -o ldif-wrap=no -H ldapi:// -Y EXTERNAL -LLL -s one -b "ou=mails,ou=trash,dc=example,dc=tld" "(&(objectClass=applicationProcess)(status=totrash))" | grep cn: | sed "s|.*: \(.*\)|\1|"')
    if not mails.nil?
      mails.each_line do |mail|
        mailname = Facter::Util::Resolution.exec('ldapsearch -o ldif-wrap=no -H ldapi:// -Y EXTERNAL -LLL -s base -b "cn=' + mail.strip + ',ou=mails,ou=trash,dc=example,dc=tld" "(&(objectClass=applicationProcess)(status=totrash))" | grep type: | sed "s|.*: \(.*\)|\1|"')
        mailhome = Facter::Util::Resolution.exec('ldapsearch -o ldif-wrap=no -H ldapi:// -Y EXTERNAL -LLL -s base -b "cn=' + mail.strip + ',ou=mails,ou=trash,dc=example,dc=tld" "(&(objectClass=applicationProcess)(status=totrash))" | grep otherPath: | sed "s|.*: \(.*\)|\1|"')
        orphanmails[mail.strip] = {:cn => mail.strip, :mail => mailname.strip, :mailhome => mailhome.strip, :trashname => mail.strip }
      end
    end
    orphanmails
  end

end
