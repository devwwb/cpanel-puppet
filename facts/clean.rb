#default fact por clean
Facter.add(:clean) do
  setcode do
    false
  end
end

