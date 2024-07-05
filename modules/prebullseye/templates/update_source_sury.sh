#!/bin/bash

echo "## Update source sury #####################################################"

#update sury repo for bullseye
if [ -f /etc/apt/sources.list.d/sury.list ]; then
  sed -i 's/buster/bullseye/g' /etc/apt/sources.list.d/sury.list
fi

#remove fake sury repo if present
if [ -f  /etc/apt/sources.list.d/suryfake.list ]; then
  rm /etc/apt/sources.list.d/suryfake.list
fi

if [ -f /etc/apt/sources.list.d/sury.list ]; then
  cat /etc/apt/sources.list.d/sury.list
fi

