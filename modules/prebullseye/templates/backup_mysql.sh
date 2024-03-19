#!/bin/bash
set -e

echo "## Backup all mysql databases ##############################################"
sleep 30
DATE=`date +%Y-%m-%d`
if [ ! -d /etc/maadix/backups ]; then
  mkdir /etc/maadix/backups
fi
sleep 2

file=/root/.my.cnf
if [ -e "$file" ]; then
  mysqldump --defaults-extra-file=/root/.my.cnf --all-databases > /etc/maadix/backups/mysql-$DATE.sql
else
  mysqldump --all-databases > /etc/maadix/backups/mysql-$DATE.sql
fi
