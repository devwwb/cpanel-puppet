#!/bin/bash

echo "## Update source torproject #####################################################"

#update torproject repo for bookworm
if [ -f /etc/apt/sources.list.d/torproject.list ]; then
  sed -i 's/bullseye/bookworm/g' /etc/apt/sources.list.d/torproject.list
fi

if [ -f /etc/apt/sources.list.d/torproject.list ]; then
  cat /etc/apt/sources.list.d/torproject.list
fi

