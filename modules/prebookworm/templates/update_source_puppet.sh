#!/bin/bash

echo "## Update source puppet8-release #####################################################"

#update puppet8-release repo for bookworm
if [ -f /etc/apt/sources.list.d/puppet8-release.list ]; then
  sed -i 's/bullseye/bookworm/g' /etc/apt/sources.list.d/puppet8-release.list
fi

if [ -f /etc/apt/sources.list.d/puppet8-release.list ]; then
  cat /etc/apt/sources.list.d/puppet8-release.list
fi

#install new puppet8-release package
apt -y update
apt install -y --allow-downgrades puppet8-release=1.0.0-10bookworm
