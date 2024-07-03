#!/bin/bash

echo "## Update source sury #####################################################"

#update sury repo for bullseye
if [ -f /etc/apt/sources.list.d/sury.list ]; then
  sed -i 's/buster/bullseye/g' /etc/apt/sources.list.d/sury.list
fi

cat /etc/apt/sources.list.d/sury.list
