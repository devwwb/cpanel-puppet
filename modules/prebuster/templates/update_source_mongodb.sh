#!/bin/bash

echo "## Update source mongo #####################################################"

#update mongo repo for buster
sed -i 's/stretch/buster/g' /etc/apt/sources.list.d/mongodb.list

cat /etc/apt/sources.list.d/mongodb.list
