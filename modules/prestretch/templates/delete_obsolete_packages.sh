#!/bin/bash

echo "## Delete obsolete packages ################################################"
#install aptitude
apt-get install aptitude -y

#remove obsolete packages
aptitude search '~o' -F '%p' | grep -v one-context | grep -v puppet-agent | grep -v linux-image | grep -v owncloud | xargs apt-get -y remove --purge
