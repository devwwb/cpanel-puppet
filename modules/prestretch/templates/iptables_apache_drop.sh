#!/bin/bash

#block http and https access while upgrading
iptables -A INPUT -p tcp --dport 443 -j DROP
iptables -A INPUT -p tcp --dport 80 -j DROP

#save iptables for next reboot
iptables-save > /etc/iptables/rules.v4

#list iptables
iptables -L

