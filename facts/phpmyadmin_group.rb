#check if phpmyadmin is installed
Facter.add(:phpmyadmin_group) do
  setcode do
    if Facter::Util::Resolution.exec('apt-show-versions | grep phpmyadmin')
      true
    else
      false
    end
  end
end

