#check if mastodon is installed
Facter.add(:mastodon_group) do
  setcode do
    if File.directory? '/var/www/mastodon/mastodon'
      true
    else
      false
    end
  end
end
