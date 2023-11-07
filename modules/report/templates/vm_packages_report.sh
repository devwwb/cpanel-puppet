#!/bin/bash

##List repositories
echo "## Repositories ############################################################"
find /etc/apt/sources.list* -type f | xargs cat

##Install apt-show-versions
echo "## Install aptitude and debsums ############################################"
apt-get install aptitude debsums -y
aptitude update

##List Packages in this server absent in the reference
echo "## List NON CANONICAL packages #############################################"
aptitude search '~i' --disable-columns -F '%p' > /tmp/<%= @lsbdistcodename %>_installed
diff /tmp/<%= @lsbdistcodename %>_reference /tmp/<%= @lsbdistcodename %>_installed | grep '>'

##List Packages in the reference absent in this server
echo "## List ABSENT packages #############################################"
diff /tmp/<%= @lsbdistcodename %>_reference /tmp/<%= @lsbdistcodename %>_installed | grep '<'

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

#Check non-Debian packages
echo "## Non-Debain packages ################################################################"
apt install apt-forktracer
apt-forktracer | sort | | awk '{print $1}'
