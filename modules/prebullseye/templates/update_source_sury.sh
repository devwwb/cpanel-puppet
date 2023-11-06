#!/bin/bash

echo "## Update source sury #####################################################"

#update sury repo for bullseye
sed -i 's/buster/bullseye/g' /etc/apt/sources.list.d/sury.list

cat /etc/apt/sources.list.d/sury.list
