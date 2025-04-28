#!/bin/bash
set -e

echo "## Upgrade bookworm #########################################################"

#stop monit
service monit stop

#upgrade bookworm
export LC_ALL=C
apt -y update
apt-get clean
apt -y upgrade --without-new-pkgs
apt-get clean
apt -y full-upgrade
apt-get clean

echo "## List deleted packages to purge #########################################################"
apt list '~c'

