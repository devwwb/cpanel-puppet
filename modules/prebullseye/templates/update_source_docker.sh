#!/bin/bash

echo "## Update source docker ####################################################"

#update docker repo for bullseye
sed -i 's/buster/bullseye/g' /etc/apt/sources.list.d/docker.list

cat /etc/apt/sources.list.d/docker.list
