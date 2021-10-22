require 'yaml'
#to debug, use STDERR and run 'puppet facts --debug | grep -A 20 fail2ban_ips' in the agent
fail2ban_ips = nil
Facter.add("fail2ban_ips") do
  setcode do
    # read ips to unlock defined in cpanel from ldap and add to fail2ban_ips fact
    fail2ban_ips_result = Facter::Util::Resolution.exec('ldapsearch -H ldapi:// -Y EXTERNAL -LLL -s base -b "ou=fail2ban,ou=cpanel,dc=example,dc=tld" "(objectClass=organizationalUnit)" | grep type: | sed "s|.*: \(.*\)|\1|"')
    if not fail2ban_ips_result.nil?
      fail2ban_ips_result.delete(' ').split(",")
    end
  end
end

