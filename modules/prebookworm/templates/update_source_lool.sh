#!/bin/bash

echo "## Update source lool ######################################################"

#update lool repo for bookworm
sed -i 's/debian11/debian12/g' /etc/apt/sources.list.d/lool.list

cat /etc/apt/sources.list.d/lool.list
