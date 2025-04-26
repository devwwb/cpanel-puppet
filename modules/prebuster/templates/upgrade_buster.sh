#!/bin/bash

echo "## Upgrade buster #########################################################"

#upgrade buster
apt update
apt list --upgradable
apt upgrade -y --allow-unauthenticated

#dist-upgrade buster
apt dist-upgrade -y --allow-unauthenticated

