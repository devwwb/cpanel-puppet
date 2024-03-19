#!/bin/bash
set -e

echo "## Upgrade bullseye #########################################################"

#upgrade bullseye
export LC_ALL=C
apt update
apt list --upgradable
apt upgrade -y

#dist-upgrade bullseye
apt dist-upgrade -y

