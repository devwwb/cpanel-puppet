#!/bin/bash

echo "## Update puppet ###########################################################"

#source
echo "deb http://apt.puppet.com stretch puppet5" > /etc/apt/sources.list.d/puppet.list

#update
apt-get update
apt-get dist-upgrade -y

