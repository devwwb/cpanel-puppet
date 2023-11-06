#!/bin/bash

echo "## Upgrade bullseye #########################################################"

#upgrade bullseye
apt update
apt list --upgradable
apt upgrade -y

#dist-upgrade bullseye
apt dist-upgrade -y

