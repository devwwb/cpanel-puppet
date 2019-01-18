#!/bin/bash

#set grub-pc options
echo "grub-pc grub-pc/install_devices multiselect /dev/vda" | debconf-set-selections

#install grub-pc
apt-get install grub-pc -y

#uninstall extlilnux
apt-get remove --purge extlinux -y
