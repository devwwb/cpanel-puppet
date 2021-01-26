#!/bin/bash

#upgrade + dist-upgrade
echo "## Upgrade packages ########################################################"
apt-get -o Acquire::Check-Valid-Until=false update
apt-get --yes --force-yes upgrade
apt-get --yes --force-yes dist-upgrade

