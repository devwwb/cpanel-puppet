#!/bin/bash

echo "## Update source sury #####################################################"

#update sury repo for bookworm
if [ -f /etc/apt/sources.list.d/sury.list ]; then
  sed -i 's/bullseye/bookworm/g' /etc/apt/sources.list.d/sury.list
fi

if [ -f /etc/apt/sources.list.d/sury.list ]; then
  cat /etc/apt/sources.list.d/sury.list
fi

