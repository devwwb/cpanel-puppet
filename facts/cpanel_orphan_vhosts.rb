require 'yaml'

##facter with deleted domains

#to debug, use STDERR and run 'puppet facts --debug | grep -A 20 cpanel_orphan_vhosts' in the agent

Facter.add(:cpanel_orphan_vhosts) do

  setcode do
    #build hash with domains that are not in ldap anymore
    orphandomains = {}
    Facter::Util::Resolution.exec('ls /etc/apache2/ldap-enabled/ | grep -v ssl | sed "s/.conf//g"').each_line do |domain|
      #if domain doesn't exist in cpanel_vhosts add to orphandomains always
      if not Facter.value(:cpanel_vhosts).key? (domain.strip)
        orphandomains[domain.strip] = {:domain => domain.strip}
      end
    end
    orphandomains
  end

end
