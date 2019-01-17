#!/bin/bash

#source
echo "deb http://apt.puppetlabs.com/ stretch PC1" > /etc/apt/sources.list.d/puppet.list

#update
apt-get update
apt-get dist-upgrade -y

#remove source
rm /etc/apt/sources.list.d/puppet.list
apt-get update
