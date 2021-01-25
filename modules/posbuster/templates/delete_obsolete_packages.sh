#!/bin/bash

echo "## Delete obsolete packages ################################################"
#install aptitude
apt-get install aptitude -y

#remove obsolete packages
aptitude update
aptitude search '~o' -F '%p' | grep -v one-context | grep -v puppet-agent | grep -v heirloom-mailx | grep -v jicofo | grep -v jitsi-meet | grep -v jitsi-videobridge2 | xargs apt-get -y remove --purge
