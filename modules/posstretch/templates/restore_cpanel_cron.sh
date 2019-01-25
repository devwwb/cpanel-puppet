#!/bin/bash

echo "## Restore cpanel crons ####################################################"

#restore cpanel cron
cd /usr/share/cpanel
git checkout -- cron/ldapsearch.sh

#restore cpanel-puppet cron
cd /usr/share/cpanel-puppet
git checkout -- cron/cpanel-puppet.sh
