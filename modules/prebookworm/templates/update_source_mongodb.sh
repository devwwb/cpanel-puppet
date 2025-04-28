#!/bin/bash

echo "## Update source mongo #####################################################"

#update mongo repo for bookworm
sed -i 's/bullseye/bookworm/g' /etc/apt/sources.list.d/mongodb.list

cat /etc/apt/sources.list.d/mongodb.list
