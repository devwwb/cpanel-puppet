#!/bin/bash

echo "## Delete stretch packages ##################################################"
#delete packages from stretch with conflicts in the upgrade

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

if [ -f /usr/bin/loolwsd ]; then
  #libreoffice-online stop
  service libreoffice-online stop
  #remove libpoco* and libreoffice*
  apt-get remove --purge libpoco* libreoffice* -y
fi

#purge php
pecl uninstall mcrypt
apt remove --purge php* -y

#purge mod wsgi
apt remove --purge libapache2-mod-wsgi* -y
