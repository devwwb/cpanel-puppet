#!/bin/bash

echo "## Update source redis #####################################################"

#update redis repo for bookworm
if [ -f /etc/apt/sources.list.d/redis.list ]; then
  sed -i 's/bullseye/bookworm/g' /etc/apt/sources.list.d/redis.list
fi

if [ -f /etc/apt/sources.list.d/redis.list ]; then
  cat /etc/apt/sources.list.d/redis.list
fi

