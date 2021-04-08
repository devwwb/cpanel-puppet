#default fact por mysql
Facter.add(:mysql) do
  setcode do
    false
  end
end

