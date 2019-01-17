
#check if onlyoffice is installed
Facter.add(:onlyoffice_group) do
  setcode do
    if Facter::Util::Resolution.which('docker')
      onlyoffice_img = Facter::Util::Resolution.exec("docker images | grep onlyoffice/documentserver | awk '{ print $3 }'")
      if (onlyoffice_img.empty?)
        false
      else
        true
      end
    else
      false
    end
  end
end

