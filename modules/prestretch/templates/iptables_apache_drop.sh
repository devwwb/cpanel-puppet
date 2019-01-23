#!/bin/bash

#block http and https access while upgrading
iptables -A INPUT -p tcp --dport 443 -j DROP
iptables -A INPUT -p tcp --dport 80 -j DROP

#list iptables
iptables -L

