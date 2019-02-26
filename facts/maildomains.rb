require 'yaml'

#to debug, use STDERR and run 'puppet facts --debug | grep -A 20 maildomains' in the agent

maildomains = nil
Facter.add("maildomains") do

  maildomains = [[], []]

  # TODO, add fqdn domain

  # THEN read mail domains defined in cpanel from ldap and add to maildomains fact
  # ONLY maildomains WITH opendkim enabled
  maildomains_result = Facter::Util::Resolution.exec('ldapsearch -H ldapi:// -Y EXTERNAL -LLL -s one -b "ou=opendkim,ou=cpanel,dc=example,dc=tld" "(objectClass=organizationalUnit)" | grep ou: | sed "s|.*: \(.*\)|\1|"')
  if not maildomains_result.nil?
      maildomains_result.each_line do |line|
          if !maildomains[0].include?(line.strip)
            maildomains[0].push(line.strip)
          end
      end
  end

  # THEN read mailman domains from psql and add to maildomains fact
  #maildomains_result = Facter::Util::Resolution.exec('sudo -u mailman psql -d mailman -A --tuples-only --field-separator="" -c "select mail_host from domain"')
  #if not maildomains_result.nil?
  #    maildomains_result.each_line do |line|
  #        if !maildomains[0].include?(line.strip)
  #          maildomains[0].push(line.strip)
  #        end
  #    end
  #end

  setcode do
    if Facter.version < '2.0.0'
      maildomains[0].join(',')
    else
      maildomains[0]
    end
  end
end

