#!/bin/bash

echo "## Update source lool ######################################################"

#update lool repo for buster
sed -i 's/debian9/debian10/g' /etc/apt/sources.list.d/lool.list

cat /etc/apt/sources.list.d/lool.list
