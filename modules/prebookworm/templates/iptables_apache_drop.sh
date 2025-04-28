#!/bin/bash

echo "## Iptables apache DROP ####################################################"
#block http and https access while upgrading if rules are not present

#ipv4
if ! iptables -C INPUT -p tcp --dport 443 -j DROP; then
  iptables -A INPUT -p tcp --dport 443 -j DROP
fi
if ! iptables -C INPUT -p tcp --dport 80 -j DROP; then
  iptables -A INPUT -p tcp --dport 80 -j DROP
fi

#ipv6
if ! ip6tables -C INPUT -p tcp --dport 443 -j DROP; then
  ip6tables -A INPUT -p tcp --dport 443 -j DROP
fi
if ! ip6tables -C INPUT -p tcp --dport 80 -j DROP; then
  ip6tables -A INPUT -p tcp --dport 80 -j DROP
fi

#list iptables
iptables -L -n
ip6tables -L -n

