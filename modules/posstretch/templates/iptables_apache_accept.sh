#!/bin/bash

echo "## Unblock http https ######################################################"

#unblock http and https access after upgrade
iptables -D INPUT -p tcp --dport 443 -j DROP
iptables -D INPUT -p tcp --dport 80 -j DROP

#delete temporary rules
rm /etc/iptables/rules.v4

#list iptables
iptables -L

