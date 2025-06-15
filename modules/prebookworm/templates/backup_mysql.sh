#!/bin/bash
set -e

echo "## Backup all mysql databases ##############################################"
sleep 30
DATE=`date +%Y-%m-%d`
if [ ! -d /home/.trash/backups ]; then
  mkdir /home/.trash/backups
fi
sleep 2

file=/root/.my.cnf
if [ -e "$file" ]; then
  mysqldump --defaults-extra-file=/root/.my.cnf --all-databases | gzip -c > /home/.trash/backups/mysql-$DATE.sql.gz
else
  mysqldump --all-databases | gzip -c > /home/.trash/backups/mysql-$DATE.sql.gz
fi
chmod 600 /home/.trash/backups/mysql-$DATE.sql.gz
