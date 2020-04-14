require 'yaml'

##facter with deleted domains

#to debug, use STDERR and run 'puppet facts --debug | grep -A 20 cpanel_orphan_vhosts' in the agent

Facter.add(:cpanel_orphan_vhosts) do

  setcode do
    #build hash with domains that are not in ldap anymore
    orphandomains = {}
    #get all domains deleted from ldap from ou=domains,ou=trash
    domains=Facter::Util::Resolution.exec('ldapsearch -H ldapi:// -Y EXTERNAL -LLL -s one -b "ou=domains,ou=trash,dc=example,dc=tld" "(&(objectClass=applicationProcess)(status=totrash))" | grep cn: | sed "s|.*: \(.*\)|\1|"')
    #array of domains from groups
    groupdomains=Facter::Util::Resolution.exec('ldapsearch -H ldapi:// -Y EXTERNAL -LLL -b "ou=groups,dc=example,dc=tld" "(ou=domain)" | grep status: | sed "s|.*: \(.*\)|\1|"').split(/\n+/)
    if not domains.nil?
      domains.each_line do |domain|
        domainname = Facter::Util::Resolution.exec('ldapsearch -H ldapi:// -Y EXTERNAL -LLL -s base -b "cn=' + domain.strip + ',ou=domains,ou=trash,dc=example,dc=tld" "(&(objectClass=applicationProcess)(status=totrash))" | grep type: | sed "s|.*: \(.*\)|\1|"')
        webroot = Facter::Util::Resolution.exec('ldapsearch -H ldapi:// -Y EXTERNAL -LLL -s base -b "cn=' + domain.strip + ',ou=domains,ou=trash,dc=example,dc=tld" "(&(objectClass=applicationProcess)(status=totrash))" | grep otherPath: | sed "s|.*: \(.*\)|\1|"')
        #if deleted vhost is in group domains don't purge certs
        if groupdomains.include? domainname.strip
          purgecerts = false
        else
          purgecerts = true
        end
        orphandomains[domain.strip] = {:cn => domain.strip, :domain => domainname.strip, :webroot => webroot.strip, :trashname => domain.strip, :purgecerts => purgecerts }
      end
    end
    orphandomains
  end

end
