#!/bin/bash

echo "## Update source debian ####################################################"

#update debian sources
echo "deb http://deb.debian.org/debian/ buster main
deb-src http://deb.debian.org/debian/ buster main
deb http://deb.debian.org/debian/ buster-updates main
deb-src http://deb.debian.org/debian/ buster-updates main
deb http://security.debian.org/debian-security buster/updates main
deb-src http://security.debian.org/debian-security buster/updates main" > /etc/apt/sources.list

cat /etc/apt/sources.list
