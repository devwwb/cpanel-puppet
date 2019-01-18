#check if phpmyadmin is installed
Facter.add(:phpmyadmin_group) do
  setcode do
    package = Facter::Util::Resolution.exec('apt-show-versions | grep phpmyadmin')
    if (package.empty?)
      false
    else
      true
    end
  end
end

