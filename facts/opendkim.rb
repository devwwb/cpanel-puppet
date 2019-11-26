#default fact por opendkim
Facter.add(:opendkim) do
  setcode do
    false
  end
end

