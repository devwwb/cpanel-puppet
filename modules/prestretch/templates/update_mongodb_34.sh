#!/bin/bash

echo "## Backup all mongodb databases ############################################"
apt-get install mongodb-org-tools -y
DATE=`date +%Y-%m-%d`
if [ ! -d /etc/maadix/backups ]; then
  mkdir /etc/maadix/backups
fi
if [ ! -d /etc/maadix/backups/mongodb-$DATE ]; then
  echo "All databases"
  mkdir /etc/maadix/backups/mongodb-$DATE
  cd /etc/maadix/backups/mongodb-$DATE
  echo -n "mongodump -u admin -p " > backup.sh
  cat /etc/maadix/mongodbadmin | tr -d '\n' | sed "s@\\\\@@g" | tr -d \'\" >> backup.sh
  chmod +x backup.sh
  ./backup.sh
  rm backup.sh
  ls -l dump/
fi

echo "## Update mongo to 3.4 #####################################################"
#if mongo version is 3.2
if mongod --version | grep v3.2; then

  #update mongo repo for mongodb 3.4
  sed -i 's/3.2/3.4/g' /etc/apt/sources.list.d/mongodb.list

  #import new key
  cd /tmp
  /usr/bin/curl -sLO https://www.mongodb.org/static/pgp/server-3.4.asc && sudo /usr/bin/apt-key add server-3.4.asc

  #update mongodb to 3.4
  apt-get update
  apt-get dist-upgrade -y
  service mongod restart

  #setFeatureCompatibilityVersion to 3.4
  sleep 10
  mongo admin --port 27017 --eval "load('/root/.mongorc.js'); db.adminCommand( { setFeatureCompatibilityVersion: '3.4' } )"

fi

