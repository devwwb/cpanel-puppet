#!/bin/bash

hostname=$(hostname)
adminmail="admin@maadix.org"

#send report
cat /etc/maadix/buster/logs/* | mail -s "Buster Upgrade | logs de ${hostname}" $adminmail

#del logs
rm /etc/maadix/buster/logs/*


