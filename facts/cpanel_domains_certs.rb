require 'yaml'

## list of letsencrypt certs in system

Facter.add(:cpanel_domains_certs) do
  setcode do   
    domains = {}
    Facter::Util::Resolution.exec('/bin/ls /etc/letsencrypt/live | sed "s/ *$//"').each_line do |domain|
      checkwww = Facter::Core::Execution.execute('/bin/cat /etc/letsencrypt/renewal/' + domain.strip + '.conf | grep www.' + domain.strip)
      if checkwww.length > 0
        domains[domain.strip] = {:domain => domain.strip, :www => true}
      else
        domains[domain.strip] = {:domain => domain.strip, :www => false}
      end 
    end
    domains
  end
end
