#!/bin/bash

echo "## Update source debian ####################################################"

#allow expired repos
echo 'Acquire::Check-Valid-Until "false";' > /etc/apt/apt.conf.d/90ignore-release-date

#update debian sources
#doc: https://debiansupport.com/mirrors/
echo "deb http://archive.debian.org/debian bullseye main
deb-src http://archive.debian.org/debian bullseye main
deb http://security.debian.org/debian-security bullseye-security main
deb-src http://security.debian.org/debian-security bullseye-security main
deb http://archive.debian.org/debian bullseye-updates main
deb-src http://archive.debian.org/debian bullseye-updates main" > /etc/apt/sources.list

#delete backports
rm /etc/apt/sources.list.d/backports.list

cat /etc/apt/sources.list
