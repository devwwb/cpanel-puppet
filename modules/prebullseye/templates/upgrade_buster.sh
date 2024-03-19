#!/bin/bash
set -e

echo "## Upgrade buster ##########################################################"

#upgrade buster
apt update
apt upgrade -y
apt dist-upgrade -y

