#check if odoo_venv3 is installed
Facter.add(:odoo_venv3_group) do
  setcode do
    if File.directory? '/var/www/odoo/venv3'
      true
    else
      false
    end
  end
end
