#!/bin/bash

echo "## Delete jessie packages ##################################################"
#delete packages from jessie with conflicts in the upgrade

if [ -f /usr/bin/fail2ban-server ]; then
  #fail2ban stop and clean iptables
  service fail2ban stop
  #remove fail2ban
  apt-get remove --purge fail2ban -y
fi

if [ -f /usr/bin/monit ]; then
  #monit stop
  service monit stop
  #remove fail2ban
  apt-get remove --purge monit -y
fi


