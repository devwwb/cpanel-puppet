#check if postgresql is installed
Facter.add(:postgresql_group) do
  setcode do
    if File.file? '/usr/lib/postgresql/9.4/bin/postgres'
      true
    else
      false
    end
  end
end
