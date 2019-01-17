#!/bin/bash

#upgrade stretch
apt-get update
apt list --upgradable
apt-get upgrade -y
apt-get dist-upgrade -y

#TODO, check exit code of dpkg commands
