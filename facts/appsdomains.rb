require 'yaml'

#to debug, use STDERR and run 'puppet facts --debug | grep -A 20 appsdomains' in the agent

appsdomains = nil
maildomains = Facter.value(:maildomains)
Facter.add("appsdomains") do

  appsdomains = [[], []]

  # THEN read app domains defined in ldap and add to appsdomains fact, only if not present in maildomains
  # ONLY appsdomains WITH field domain
  appsdomains_result = Facter::Util::Resolution.exec('ldapsearch -H ldapi:// -Y EXTERNAL -LLL -b "ou=groups,dc=example,dc=tld" "(&(objectClass=organizationalUnit)(ou=domain))" | grep status: | sed "s|.*: \(.*\)|\1|"')
  if not appsdomains_result.nil?
      appsdomains_result.each_line do |line|
          if !appsdomains[0].include?(line.strip) && !maildomains.include?(line.strip)
            appsdomains[0].push(line.strip)
          end
      end
  end

  setcode do
    if Facter.version < '2.0.0'
      appsdomains[0].join(',')
    else
      appsdomains[0]
    end
  end
end

