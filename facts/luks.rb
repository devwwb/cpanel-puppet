#default fact por luks
Facter.add(:luks) do
  setcode do
    false
  end
end

