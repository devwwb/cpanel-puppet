#check if lool is installed
Facter.add(:lool_group) do
  setcode do
    if File.file? '/etc/apt/sources.list.d/lool.list'
      true
    else
      false
    end
  end
end
