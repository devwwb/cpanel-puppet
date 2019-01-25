#!/bin/bash

echo "## Upgrade jessie ##########################################################"

#upgrade jessie
apt-get update
apt-get upgrade -y
apt-get dist-upgrade -y

