#default fact por borgbackup
Facter.add(:borgbackup) do
  setcode do
    false
  end
end

