#!/bin/bash

echo "## Unblock http https ######################################################"

#unblock http and https access after upgrade
iptables -D INPUT -p tcp --dport 443 -j DROP
iptables -D INPUT -p tcp --dport 80 -j DROP

#delete temporary rules
if [[ -f /etc/iptables/rules.v4 ]]; then
  rm /etc/iptables/rules.v4
fi

#list iptables
iptables -L

