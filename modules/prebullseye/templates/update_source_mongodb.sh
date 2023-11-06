#!/bin/bash

echo "## Update source mongo #####################################################"

#update mongo repo for bullseye
sed -i 's/buster/bullseye/g' /etc/apt/sources.list.d/mongodb.list

cat /etc/apt/sources.list.d/mongodb.list
