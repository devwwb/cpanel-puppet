#!/bin/bash

#unblock http and https access after upgrade
iptables -D INPUT -p tcp --dport 443 -j DROP
iptables -D INPUT -p tcp --dport 80 -j DROP

#list iptables
iptables -L

