#check if one-context is installed
Facter.add(:one_context) do
  setcode do
    package = Facter::Util::Resolution.exec('apt-show-versions | grep one_context')
    if (package.empty?)
      false
    else
      true
    end
  end
end
