#!/bin/bash

echo "## Update onecontext #######################################################"

#download new package
wget https://github.com/OpenNebula/addon-context-linux/releases/download/v5.6.0/one-context_5.6.0-1.deb -O /tmp/one-context_5.6.0-1.deb

#install dependencies
apt-get install curl parted open-vm-tools qemu-guest-agent libcurl3 -y

#update one-context
dpkg -i /tmp/one-context_5.6.0-1.deb
