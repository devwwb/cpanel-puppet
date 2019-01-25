#!/bin/bash

#save iptables for next reboot
iptables-save > /etc/iptables/rules.v4

#list iptables
iptables -L

