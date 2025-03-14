require 'yaml'
require 'socket'
require 'ipaddr'

##list of domains in cpanel with and without dns resolution

#to debug, use STDERR and run 'puppet facts --debug | grep -A 20 cpanel_domains' in the agent

ipv4obj = IPAddr.new Facter.value(:public_ipv4)
begin
  ipv6obj = IPAddr.new Facter.value('maadix_networking.ipv6.ip')
rescue
  ipv6obj = IPAddr.new Facter.value(:public_ipv4)
end

Facter.add(:cpanel_domains) do
  setcode do
    domains = {}
    Facter::Util::Resolution.exec('ldapsearch -H ldapi:// -Y EXTERNAL -LLL -s one -b "o=hosting,dc=example,dc=tld" "(objectClass=VirtualDomain)" | grep vd: | sed "s|.*: \(.*\)|\1|"').each_line do |domain|
      ip = ''
      ipwww = ''
      #if domain have certs, add to domains, else check if dns is ok before adding to domains
      if Facter.value(:cpanel_domains_certs).key? (domain.strip)
        #if cert doesn't include domain with www, check if it's available to add it and regenerate the cert
        if Facter.value(:cpanel_domains_certs)[domain.strip]['www'] == false
          begin
            #check if domain has www. DNS and create IPAddr object
            ipwww = IPSocket::getaddress('www.' + domain.strip)
            ipwwwobj = IPAddr.new ipwww
            #if domain point to this ip
            if ipwwwobj == ipv4obj || ipwwwobj == ipv6obj
              domains[domain.strip] = {:domain => domain.strip, :www => true, :regenerate => true, :dns => true}
            else
              domains[domain.strip] = {:domain => domain.strip, :www => false, :regenerate => false, :dns => true}
            end
          rescue SocketError
            domains[domain.strip] = {:domain => domain.strip, :www => false, :regenerate => false, :dns => true}
          end
        else
          domains[domain.strip] = {:domain => domain.strip, :www => Facter.value(:cpanel_domains_certs)[domain.strip]['www'], :regenerate => false, :dns => true}
        end
      else
        begin
          #check if domain has DNS and create IPAddr object
          ip = IPSocket::getaddress(domain.strip)
          #p domain + ' ' + ip
          ipobj = IPAddr.new ip
          #if domain point to this ip
          if ipobj == ipv4obj || ipobj == ipv6obj
            begin
              #check if domain has www. DNS and create IPAddr object
              ipwww = IPSocket::getaddress('www.' + domain.strip)
              #p 'www' + domain + ' ' + ip
              ipwwwobj = IPAddr.new ipwww
              #if domain point to this ip
              if ipwwwobj == ipv4obj || ipwwwobj == ipv6obj
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
