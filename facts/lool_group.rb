#check if lool is installed
Facter.add(:lool_group) do
  setcode do
    if File.file? '/etc/apt/sources.list.d/collabora.sources'
      true
    else
      false
    end
  end
end
