#!/bin/bash

echo "## Update source nginx #####################################################"

#update nginx repo for bookworm
if [ -f /etc/apt/sources.list.d/nginx.list ]; then
  sed -i 's/bullseye/bookworm/g' /etc/apt/sources.list.d/nginx.list
fi

if [ -f /etc/apt/sources.list.d/nginx.list ]; then
  cat /etc/apt/sources.list.d/nginx.list
fi

