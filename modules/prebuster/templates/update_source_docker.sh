#!/bin/bash

echo "## Update source docker ####################################################"

#update docker repo for buster
sed -i 's/stretch/buster/g' /etc/apt/sources.list.d/docker.list

cat /etc/apt/sources.list.d/docker.list

