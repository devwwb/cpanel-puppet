#!/bin/bash

hostname=$(hostname)
adminmail="admin@maadix.org"

#send report
cat /etc/maadix/buster/logs/prebuster | mail -s "Buster Upgrade | prebuster logs de ${hostname}" $adminmail


