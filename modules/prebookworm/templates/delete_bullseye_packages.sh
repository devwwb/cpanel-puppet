#!/bin/bash

echo "## Delete bullseye packages ##################################################"
#delete packages from bullseye with issues in the upgrade

#purge rkhunter and ntp
apt remove --purge rkhunter ntp -y

#purge aufs packages
apt remove --purge aufs-dkms aufs-tools -y
