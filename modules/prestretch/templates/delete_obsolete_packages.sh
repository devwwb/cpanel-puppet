#!/bin/bash

#install aptitude
apt-get install aptitude -y

#remove obsolete packages
aptitude search '~o' -F '%p' | grep -v one-context | grep -v puppet-agent | grep -v linux-image | xargs apt-get -y remove --purge
