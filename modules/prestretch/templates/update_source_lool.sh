#!/bin/bash

echo "## Update source lool ######################################################"

#update lool repo for stretch
sed -i 's/repos/stretch/g' /etc/apt/sources.list.d/lool.list
sed -i 's/jessie/stretch/g' /etc/apt/sources.list.d/lool.list

cat /etc/apt/sources.list.d/lool.list
