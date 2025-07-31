#!/bin/bash

echo "## Update source debian ####################################################"

#update debian sources
echo "deb http://archive.debian.org/debian/ buster main
deb-src http://archive.debian.org/debian/ buster main
deb http://archive.debian.org/debian/ buster-updates main
deb-src http://archive.debian.org/debian/ buster-updates main
deb http://archive.debian.org/debian-security buster/updates main
deb-src http://archive.debian.org/debian-security buster/updates main" > /etc/apt/sources.list

cat /etc/apt/sources.list
