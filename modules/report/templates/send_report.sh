#!/bin/bash

hostname=$(hostname)
adminmail="admin@maadix.org"

#send report
cat -v /etc/maadix/report/logs/* | mail -s "Report | Infome de ${hostname}" $adminmail

#del logs
rm /etc/maadix/stretch/logs/*
