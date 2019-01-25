#!/bin/bash

#upgrade stretch
apt-get update
apt list --upgradable
apt-get upgrade -y

if [ -f /root/.my.cnf ]; then
  #delete root /.my.conf
  rm /root/.my.cnf
fi

#dist-upgrade stretch
apt-get dist-upgrade -y

