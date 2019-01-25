#!/bin/bash

echo "## Update source docker ####################################################"

#update docker repo for stretch
sed -i 's/jessie/stretch/g' /etc/apt/sources.list.d/docker.list

cat /etc/apt/sources.list.d/docker.list

