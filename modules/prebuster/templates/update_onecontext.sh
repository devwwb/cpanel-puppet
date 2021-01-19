#!/bin/bash

echo "## Update one-context #######################################################"

#remove old package
apt-get remove --purge one-context -y

#download new package
wget https://github.com/OpenNebula/addon-context-linux/releases/download/v5.12.0.1/one-context_5.12.0.1-1.deb -O /tmp/one-context_5.12.0.1-1.deb

#install dependencies
apt-get install acpid curl parted open-vm-tools qemu-guest-agent libcurl4 -y

#update one-context
dpkg -i /tmp/one-context_5.12.0.1-1.deb
