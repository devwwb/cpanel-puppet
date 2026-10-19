require 'yaml'
require 'etc'

##facter with vhost params for each domain

#to debug, use STDERR and run 'puppet facts --debug | grep -A 20 cpanel_pools' in the agent

Facter.add(:cpanel_pools, :type => :aggregate ) do

  #fpm pool
  chunk(:pool) do
    vhosts = {}
    Facter.value(:cpanel_domains).each do |domain, value|
      pool=Facter::Util::Resolution.exec('ldapsearch -H ldapi:// -Y EXTERNAL -LLL -s base -b "vd=' + domain.strip + ',o=hosting,dc=example,dc=tld" "(objectClass=VirtualDomain)" | grep type: | sed "s|.*: \(.*\)|\1|"')
      if not pool.empty?
        vhosts[pool] = {:pool => pool}
      else
        vhosts[pool] = {:pool => 'www'}
      end
    end
    vhosts
  end

end

