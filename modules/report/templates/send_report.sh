#!/bin/bash

hostname=$(hostname)
adminmail="admin@maadix.org"

#send report
cat /etc/maadix/report/logs/* | mail -s "Stretch Upgrade: solicitud desde ${hostname}" $adminmail

