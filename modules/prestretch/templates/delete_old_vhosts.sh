#!/bin/bash

echo "## Delete old vhosts #######################################################"

if [ -z "$(ls -A /etc/apache2/ldap-enabled)" ]; then
   echo "Directory empty"
else
   echo "Deleting old vhosts:"
   ls -l /etc/apache2/ldap-enabled
   rm /etc/apache2/ldap-enabled/*
fi
