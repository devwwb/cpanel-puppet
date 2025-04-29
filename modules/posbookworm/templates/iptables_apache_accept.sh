#!/bin/bash

echo "## Unblock http https ######################################################"

#unblock http and https access after upgrade

#ipv4
if iptables -C INPUT -p tcp --dport 443 -j DROP; then
  iptables -D INPUT -p tcp --dport 443 -j DROP
fi
if iptables -C INPUT -p tcp --dport 80 -j DROP; then
  iptables -D INPUT -p tcp --dport 80 -j DROP
fi

#ipv6
if ip6tables -C INPUT -p tcp --dport 443 -j DROP; then
  ip6tables -D INPUT -p tcp --dport 443 -j DROP
fi
if ip6tables -C INPUT -p tcp --dport 80 -j DROP; then
  ip6tables -D INPUT -p tcp --dport 80 -j DROP
fi

#delete temporary rules
if [[ -f /etc/iptables/rules.v4 ]]; then
  rm /etc/iptables/rules.v4
fi
if [[ -f /etc/iptables/rules.v6 ]]; then
  rm /etc/iptables/rules.v6
fi

#list iptables
iptables -L -n
ip6tables -L -n
