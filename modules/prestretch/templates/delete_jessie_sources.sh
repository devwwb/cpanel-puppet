#!/bin/bash

#delete jessie sources
if [ -f /etc/apt/sources.list.d/backports.list ]; then
  rm /etc/apt/sources.list.d/backports.list
fi
if [ -f /etc/apt/sources.list.d/nodesource.list ]; then
  rm /etc/apt/sources.list.d/nodesource.list
fi
if [ -f /etc/apt/sources.list.d/owncloud.list ]; then
  rm /etc/apt/sources.list.d/owncloud.list
fi

#delete jessie apt conf
if [ -f /etc/apt/apt.conf.d/90ignore-release-date ]; then
  rm /etc/apt/apt.conf.d/90ignore-release-date
fi

