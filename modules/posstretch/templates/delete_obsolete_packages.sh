#!/bin/bash

echo "## Delete obsolete packages ################################################"
#install aptitude
apt-get install aptitude -y

#remove obsolete packages
aptitude update
aptitude search '~o' -F '%p' | grep -v one-context | grep -v puppet-agent | xargs apt-get -y remove --purge
