#check if discourse is installed
Facter.add(:discourse_group) do
  setcode do
    if File.directory? '/var/discourse'
      true
    else
      false
    end
  end
end
