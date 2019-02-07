#!/bin/bash

echo "## Backup all mysql databases ##############################################"
DATE=`date +%Y-%m-%d`
if [ ! -d /etc/maadix/backups ]; then
  mkdir /etc/maadix/backups
fi
mysqldump --all-databases > /etc/maadix/backups/mysql-$DATE.sql
