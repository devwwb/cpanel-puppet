#!/bin/bash

echo "## Update source docker ####################################################"

#update docker repo for bookworm
sed -i 's/bullseye/bookworm/g' /etc/apt/sources.list.d/docker.list

cat /etc/apt/sources.list.d/docker.list
