#!/bin/bash

#upgrade + dist-upgrade
echo "## Upgrade packages ########################################################"
apt-get -o Acquire::Check-Valid-Until=false update
apt-get upgrade -y
apt-get dist-upgrade -y

