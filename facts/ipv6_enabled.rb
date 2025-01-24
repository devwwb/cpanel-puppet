#check if ipv6 is enabled
Facter.add(:ipv6_enabled) do
  setcode do
    status = Facter::Core::Execution.execute('ldapsearch -H ldapi:// -Y EXTERNAL -LLL -s base -b "ou=ipv6,ou=conf,ou=cpanel,dc=example,dc=tld" | grep status: | sed "s|.*: \(.*\)|\1|"') rescue 'false'
    case status
    when /TRUE/
      ipv6_enabled = true
    else
      ipv6_enabled = false
    end
  end
end

