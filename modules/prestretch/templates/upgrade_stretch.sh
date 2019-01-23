#!/bin/bash

#upgrade stretch
apt-get update
apt list --upgradable
apt-get upgrade -y

#delete root /.my.conf
rm /root/.my.cnf

#dist-upgrade stretch
apt-get dist-upgrade -y

#TODO, check exit code of dpkg commands
