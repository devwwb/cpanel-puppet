#!/bin/bash

hostname=$(hostname)
adminmail="admin@maadix.org"

#send report
cat /etc/maadix/stretch/logs/* | mail -s "Stretch Upgrade | Prestretch logs de ${hostname}" $adminmail

#del logs
rm /etc/maadix/stretch/logs/*


