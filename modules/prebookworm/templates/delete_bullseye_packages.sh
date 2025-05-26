#!/bin/bash

echo "## Delete bullseye packages ##################################################"
#delete packages from bullseye with issues in the upgrade

#purge rkhunter and ntp
apt remove --purge rkhunter ntp -y

#purge aufs packages
apt remove --purge aufs-dkms aufs-tools -y

#delete old libwacom2
apt remove libinput10 libwacom2 -y

#delete old docker-compose
if [ -f /usr/local/bin/docker-compose ]; then
  rm /usr/local/bin/docker-compose*
fi
