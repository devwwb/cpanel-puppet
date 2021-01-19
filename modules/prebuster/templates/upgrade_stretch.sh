#!/bin/bash

echo "## Upgrade stretch ##########################################################"

#upgrade stretch
apt update
apt upgrade -y
apt dist-upgrade -y

