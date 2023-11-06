#!/bin/bash

echo "## Update source lool ######################################################"

#update lool repo for bullseye
sed -i 's/debian10/debian11/g' /etc/apt/sources.list.d/lool.list

cat /etc/apt/sources.list.d/lool.list
