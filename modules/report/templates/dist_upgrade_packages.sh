#!/bin/bash

#upgrade + dist-upgrade
echo "## Upgrade packages ########################################################"
apt-get update
apt-get upgrade -y
apt-get dist-upgrade -y

