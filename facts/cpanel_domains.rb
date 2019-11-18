require 'yaml'
require 'socket'

##list of domains in cpanel with dns resolution

#to debug, use STDERR and run 'puppet facts --debug | grep -A 20 cpanel_domains' in the agent

Facter.add(:cpanel_domains) do
  setcode do
    domains = {}
    Facter::Util::Resolution.exec('ldapsearch -H ldapi:// -Y EXTERNAL -LLL -s one -b "o=hosting,dc=example,dc=tld" "(objectClass=VirtualDomain)" | grep vd: | sed "s|.*: \(.*\)|\1|"').each_line do |domain|
      #if domain have certs, add to domains, else check if dns is ok before adding to domains
      if Facter.value(:cpanel_domains_certs).key? (domain.strip)
        #if cert doesn't include domain with www, check if it's available to add it and regenerate the cert
        if Facter.value(:cpanel_domains_certs)[domain.strip][:www] == false
          begin
            IPSocket::getaddress('www.' + domain.strip) == Facter.value(:ipaddress)
            domains[domain.strip] = {:domain => domain.strip, :www => true, :regenerate => true}
          rescue SocketError
            domains[domain.strip] = {:domain => domain.strip, :www => false, :regenerate => false}            
          end
        else
          domains[domain.strip] = {:domain => domain.strip, :www => Facter.value(:cpanel_domains_certs)[domain.strip][:www], :regenerate => false}
        end
      else
        if IPSocket::getaddress(domain.strip) == Facter.value(:ipaddress)
          if IPSocket::getaddress('www.' + domain.strip) == Facter.value(:ipaddress)
            domains[domain.strip] = {:domain => domain.strip, :www => true, :regenerate => false}
          else
            domains[domain.strip] = {:domain => domain.strip, :www => false, :regenerate => false}
          end
        end
      end
    end
    domains
  end
end

