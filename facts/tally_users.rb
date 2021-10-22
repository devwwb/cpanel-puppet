require 'yaml'
#to debug, use STDERR and run 'puppet facts --debug | grep -A 20 tally_users' in the agent
tally_users = nil
Facter.add("tally_users") do
  setcode do
    # read users to unlock defined in cpanel from ldap and add to tally_users fact
    tally_users_result = Facter::Util::Resolution.exec('ldapsearch -H ldapi:// -Y EXTERNAL -LLL -s base -b "ou=tally,ou=cpanel,dc=example,dc=tld" "(objectClass=organizationalUnit)" | grep type: | sed "s|.*: \(.*\)|\1|"')
    if not tally_users_result.nil?
      tally_users_result.delete(' ').split(",")
    end
  end
end

