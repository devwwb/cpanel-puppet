#!/bin/bash

##Install apt-show-versions
echo "## Install apt-show-versions ###############################################"
apt-get install apt-show-versions -y

##List Installed packages
echo "## List Installed packages #################################################"
apt-show-versions

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

