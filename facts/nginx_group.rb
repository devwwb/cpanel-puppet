#check if nginx is installed
Facter.add(:nginx_group) do
  setcode do
    if Facter::Util::Resolution.which('nginx')
      true
    else
      false
    end
  end
end

