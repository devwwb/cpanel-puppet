#check if openvpn is installed
Facter.add(:openvpn_group) do
  setcode do
    package = Facter::Util::Resolution.exec('apt-show-versions | grep openvpn')
    if (package.empty?)
      false
    else
      true
    end
  end
end

