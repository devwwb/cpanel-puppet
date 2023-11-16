require 'yaml'
require 'socket'

##list of domains in cpanel with and without dns resolution

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
            IPSocket::getaddress('www.' + domain.strip)
            if IPSocket::getaddress('www.' + domain.strip) == Facter.value(:public_ip)
              domains[domain.strip] = {:domain => domain.strip, :www => true, :regenerate => true, :dns => true}
            else
              domains[domain.strip] = {:domain => domain.strip, :www => false, :regenerate => false, :dns => true}
            end
          rescue SocketError
            domains[domain.strip] = {:domain => domain.strip, :www => false, :regenerate => false, :dns => true}
          end
        else
          domains[domain.strip] = {:domain => domain.strip, :www => Facter.value(:cpanel_domains_certs)[domain.strip][:www], :regenerate => false, :dns => true}
        end
      else
        begin
          #check if domain has DNS
          IPSocket::getaddress(domain.strip)
          #if domain point to this ip
          if IPSocket::getaddress(domain.strip) == Facter.value(:public_ip)
            begin
              #check if domain as www. DNS resolution
              IPSocket::getaddress('www.' + domain.strip)
              if IPSocket::getaddress('www.' + domain.strip) == Facter.value(:public_ip)
                domains[domain.strip] = {:domain => domain.strip, :www => true, :regenerate => false, :dns => true}
              else
                domains[domain.strip] = {:domain => domain.strip, :www => false, :regenerate => false, :dns => true}
              end
            rescue SocketError
              domains[domain.strip] = {:domain => domain.strip, :www => false, :regenerate => false, :dns => true}
            end
          else
            #the domain has DNS but not pointing to this IP
            domains[domain.strip] = {:domain => domain.strip, :www => false, :regenerate => false, :dns => false}
          end
        rescue SocketError
          #the domain has not DNS
          domains[domain.strip] = {:domain => domain.strip, :www => false, :regenerate => false, :dns => false}
        end
      end
    end
    domains
  end
end

