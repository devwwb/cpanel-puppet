#!/bin/bash

echo "## Update source debian ####################################################"

#update debian sources
echo "deb http://deb.debian.org/debian stretch main
deb-src http://deb.debian.org/debian stretch main
deb http://deb.debian.org/debian-security/ stretch/updates main
deb-src http://deb.debian.org/debian-security/ stretch/updates main
deb http://deb.debian.org/debian stretch-updates main
deb-src http://deb.debian.org/debian stretch-updates main" > /etc/apt/sources.list

cat /etc/apt/sources.list
