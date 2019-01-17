#check if mongodb is installed
Facter.add(:mongodb_group) do
  setcode do
    if File.file? '/usr/bin/mongod'
      true
    else
      false
    end
  end
end
