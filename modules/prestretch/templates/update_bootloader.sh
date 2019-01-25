#!/bin/bash

echo "## Update bootloader #######################################################"

#set grub-pc options
echo "grub-pc grub-pc/install_devices multiselect /dev/vda" | debconf-set-selections

#install grub-pc
apt-get install grub-pc -y

#uninstall extlilnux
apt-get remove --purge extlinux -y

#remove extlinux conf
if [ -f /boot/extlinux/extlinux.conf ]; then
  rm /boot/extlinux/extlinux.conf
fi
