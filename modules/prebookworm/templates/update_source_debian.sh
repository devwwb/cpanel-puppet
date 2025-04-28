#!/bin/bash

echo "## Update source debian ####################################################"

#update debian sources
echo "deb http://deb.debian.org/debian bookworm main
deb-src http://deb.debian.org/debian bookworm main
deb http://security.debian.org/debian-security bookworm-security main
deb-src http://security.debian.org/debian-security bookworm-security main
deb http://deb.debian.org/debian bookworm-updates main
deb-src http://deb.debian.org/debian bookworm-updates main" > /etc/apt/sources.list

#delete backports
rm /etc/apt/sources.list.d/backports.list

cat /etc/apt/sources.list
