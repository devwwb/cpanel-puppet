#check if tor is installed
Facter.add(:tor_group) do
  setcode do
    if File.file? '/etc/apt/sources.list.d/torproject.list'
      true
    else
      false
    end
  end
end
