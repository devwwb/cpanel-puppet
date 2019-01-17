#!/bin/bash

#disable cpanel cron
echo " " > /usr/share/cpanel/cron/puppetcron.sh
echo " " > /usr/share/cpanel/cron/ldapsearch.sh
echo " " > /usr/share/cpanel-puppet/cron/cpanel-puppet.sh


