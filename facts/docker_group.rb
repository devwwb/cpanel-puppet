#check if docker is installed
Facter.add(:docker_group) do
  setcode do
    if Facter::Util::Resolution.which('docker')
      true
    else
      false
    end
  end
end

