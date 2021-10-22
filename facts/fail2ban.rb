#default fact por fail2ban
Facter.add(:fail2ban) do
  setcode do
    false
  end
end

