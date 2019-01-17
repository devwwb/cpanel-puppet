#check if mailman_venv3 is installed
Facter.add(:mailman_venv3_group) do
  setcode do
    if File.directory? '/opt/mailman/venv3'
      true
    else
      false
    end
  end
end
