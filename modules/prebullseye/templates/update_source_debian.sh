#!/bin/bash

echo "## Update source debian ####################################################"

#update debian sources
echo "deb http://archive.debian.org/debian bullseye main
deb-src http://archive.debian.org/debian bullseye main
deb http://archive.debian.org/debian-security bullseye-security main
deb-src http://archive.debian.org/debian-security bullseye-security main
deb http://archive.debian.org/debian bullseye-updates main
deb-src http://archive.debian.org/debian bullseye-updates main" > /etc/apt/sources.list

#delete backports
rm /etc/apt/sources.list.d/backports.list

cat /etc/apt/sources.list
