require 'yaml'

##facter with vhost params for each domain

#to debug, use STDERR and run 'puppet facts --debug | grep -A 20 cpanel_vhosts' in the agent

Facter.add(:cpanel_vhosts, :type => :aggregate ) do

  #domain name
  chunk(:domain) do
    vhosts = {}
    Facter.value(:cpanel_domains).each do |domain, value|
      vhosts[domain.strip] = value
    end
    vhosts
  end

  #webmaster and webmaster_type
  chunk(:webmaster) do
    vhosts = {}

    Facter.value(:cpanel_domains).each do |domain, value|
      webmaster=Facter::Util::Resolution.exec('ldapsearch -H ldapi:// -Y EXTERNAL -LLL -s base -b "vd=' + domain.strip + ',o=hosting,dc=example,dc=tld" "(objectClass=VirtualDomain)" | grep adminID: | sed "s|.*: \(.*\)|\1|"')
      Facter.value(:cpanel_users)[webmaster.strip][:type]
      vhosts[domain.strip] = {:webmaster => webmaster.strip, :webmaster_type => Facter.value(:cpanel_users)[webmaster.strip][:type]}
    end

    vhosts
  end

  #todo, add extra vhosts options to parse in the template file

end
