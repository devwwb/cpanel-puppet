#!/bin/bash

echo "## Backup all mongodb databases ############################################"
apt-get install mongodb-org-tools -y --force-yes
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

echo "## Update mongo to 4.0 #####################################################"
#if mongo version is 3.6
if mongod --version | grep v3.6; then

  #Upgrade MONGODB-CR to SCRAM
  echo 'db.adminCommand({authSchemaUpgrade: 1});' | mongo --ssl --sslAllowInvalidCertificates localhost/admin

  #Set Compatibility version to 3.6
  echo 'db.adminCommand( { setFeatureCompatibilityVersion: "3.6" } )' | mongo --ssl --sslAllowInvalidCertificates localhost/admin

  #update mongo repo for mongodb 4.0
  apt-key list | grep -C 5 mongo
  apt-key del '2930 ADAE 8CAF 5059 EE73  BB4B 5871 2A22 91FA 4AD5'
  curl 'https://www.mongodb.org/static/pgp/server-4.0.asc' | apt-key add -
  sed -i 's/3.6/4.0/g' /etc/apt/sources.list.d/mongodb.list

  #update mongodb to 4.0
  apt update
  apt upgrade mongodb-org-{server,shell,tools} -y
  service mongod restart

  #setFeatureCompatibilityVersion to 4.0
  sleep 30
  mongo admin --port 27017 --eval "load('/root/.mongorc.js'); db.adminCommand( { setFeatureCompatibilityVersion: '4.0' } )"

fi


echo "## Update mongo to 4.2 #####################################################"
#if mongo version is 4.0
if mongo --version | grep v4.0; then

  #update mongo repo for mongodb 4.2
  apt-key list | grep -C 5 mongo
  apt-key del '9DA3 1620 334B D75D 9DCB  49F3 6881 8C72 E525 29D4'
  curl 'https://www.mongodb.org/static/pgp/server-4.2.asc' | apt-key add -
  sed -i -E 's/4[.]0/4.2/g' /etc/apt/sources.list.d/mongodb.list

  #update mongodb to 4.2
  apt update
  apt upgrade mongodb-org-{server,shell,tools} -y
  service mongod restart

  #setFeatureCompatibilityVersion to 4.2
  sleep 30
  mongo admin --port 27017 --eval "load('/root/.mongorc.js'); db.adminCommand( { setFeatureCompatibilityVersion: '4.2' } )"

fi
