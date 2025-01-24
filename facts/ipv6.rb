#default fact por ipv6
Facter.add(:ipv6) do
  setcode do
    false
  end
end

