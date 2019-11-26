#default fact por reboot
Facter.add(:reboot) do
  setcode do
    false
  end
end

