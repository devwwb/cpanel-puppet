#!/bin/bash

hostname=$(hostname)
adminmail="admin@maadix.org"

#get user email
url="ldapi://"
basedn="dc=example,dc=tld"
useremail=`ldapsearch -Q -Y EXTERNAL -H "$url" -b "$basedn" -s one "(&(objectclass=simpleSecurityObject)(status=active))" | awk -F ": " '$1 == "email" {print $2}'`


#send report
cat -v /etc/maadix/report/logs/* | mail -s "Report | Infome de ${hostname}" $adminmail
cat -v /etc/maadix/report/logs/* | mail -s "Report | Infome de ${hostname}" $useremail

#del logs
rm /etc/maadix/report/logs/*
