#!/bin/bash

echo "## Upgrade buster #########################################################"

#upgrade buster
apt update
apt list --upgradable
apt upgrade -y

#dist-upgrade buster
apt dist-upgrade -y

