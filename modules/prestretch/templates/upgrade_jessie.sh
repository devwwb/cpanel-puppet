#!/bin/bash

echo "## Upgrade jessie ##########################################################"

#upgrade jessie
apt-get -o Acquire::Check-Valid-Until=false update
apt-get upgrade -y
apt-get dist-upgrade -y

