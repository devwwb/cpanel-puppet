#!/bin/bash

##List repositories
echo "## Repositories ############################################################"
find /etc/apt/sources.list* -type f | xargs cat

##Install apt-show-versions
echo "## Install aptitude and debsums ############################################"
apt-get install aptitude debsums -y
aptitude update

##List Installed packages
echo "## List Installed packages #################################################"
aptitude search '~i' --disable-columns -F '%p'

#Check all debian binaries against the checksum of the original
echo "## Debsums #################################################################"
debsums -a | grep -v OK

##Check that no packages are on hold by querying the package database
echo "## Dpkg audit ##############################################################"
dpkg --audit
#if there's no packages marked as hold, return true instead exit code 1
echo "## Hold packages ###########################################################"
dpkg --get-selections | grep hold || true

##Database sanity and consistency checks for partially installed, missing and obsolete packages
echo "## Dpkg sanity check #######################################################"
dpkg -C

##Check what packages are held back
echo "## Showhold ################################################################"
apt-mark showhold

##Check files integrity with samhain
echo "## Samhain ################################################################"
samhain -t check

