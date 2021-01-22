#!/bin/bash

hostname=$(hostname)
adminmail="admin@maadix.org"

#send report
cat /etc/maadix/buster/logs/posbuster | mail -s "Buster Upgrade | posbuster logs de ${hostname}" $adminmail


