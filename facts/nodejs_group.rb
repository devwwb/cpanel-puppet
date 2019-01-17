#check if nodejs is installed
Facter.add(:nodejs_group) do
  setcode do
    if File.file? '/usr/bin/node'
      true
    else
      false
    end
  end
end
