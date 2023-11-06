#!/bin/bash

echo "## Backup all mongodb databases ############################################"
apt install mongodb-org-tools -y --force-yes
apt install netcat -y
DATE=`date +%Y-%m-%d`
if [ ! -d /etc/maadix/backups ]; then
  mkdir /etc/maadix/backups
fi
if [ ! -d /etc/maadix/backups/mongodb-$DATE ]; then
  echo "All databases"
  mkdir /etc/maadix/backups/mongodb-$DATE
  cd /etc/maadix/backups/mongodb-$DATE
  echo -n "mongodump --host localhost --port 27017 --ssl --sslCAFile /opt/mongod/certs/rootCA.crt -u admin -p " > backup.sh
  cat /etc/maadix/mongodbadmin | tr -d '\n' | sed "s@\\\\@@g" | tr -d \'\" >> backup.sh
  chmod +x backup.sh
  #wait until mongod is up
  while ! nc -z localhost 27017; do
    echo "waiting mongod 4.4"
    sleep 5
  done
  echo "mongod 4.4 running"
  ./backup.sh
  rm backup.sh
  echo "Backup mongodb databases:"
  ls -l dump/
fi

echo "## Update mongo to 5.0 #####################################################"
#if mongo version is 4.4
if mongod --version | grep v4.4; then

  #Set Compatibility version to 4.4
  mongo admin --host localhost --port 27017 --ssl --sslCAFile /opt/mongod/certs/rootCA.crt --eval "load('/root/.mongorc.js'); db.adminCommand( { setFeatureCompatibilityVersion: '4.4' } )"

  #update mongo repo for mongodb 5.0
  apt-key list | grep -C 5 mongo
  apt-key del '2069 1EEC 3521 6C63 CAF6  6CE1 6564 08E3 90CF B1F5'
  wget -qO - https://www.mongodb.org/static/pgp/server-5.0.asc | apt-key add -
  sed -i 's/4.4/5.0/g' /etc/apt/sources.list.d/mongodb.list

  #update mongodb to 5.0
  apt update
  service monit stop
  service mongod stop
  apt remove mongodb-org-database-tools-extra mongodb-org-tools -y
  apt install mongodb-org-{server,shell,tools,database-tools-extra} -y
  sleep 10
  service mongod restart

  #wait until mongod is up
  while ! nc -z localhost 27017; do
    echo "waiting mongod 5.0"
    sleep 1
  done
  echo "mongod 5.0 running"

  #setFeatureCompatibilityVersion to 5.0
  until mongo admin --host localhost --port 27017 --ssl --sslCAFile /opt/mongod/certs/rootCA.crt --eval "load('/root/.mongorc.js'); db.adminCommand( { getParameter: 1, featureCompatibilityVersion: 1 } )" | grep version | grep -v shell | grep -v server | grep 5.0
  do
    sleep 5
    echo "Trying to setFeatureCompatibilityVersion: '5.0'"
    mongo admin --host localhost --port 27017 --ssl --sslCAFile /opt/mongod/certs/rootCA.crt --eval "load('/root/.mongorc.js'); db.adminCommand( { setFeatureCompatibilityVersion: '5.0' } )"
  done

  #log
  mongo admin --host localhost --port 27017 --ssl --sslCAFile /opt/mongod/certs/rootCA.crt --eval "load('/root/.mongorc.js'); db.adminCommand( { getParameter: 1, featureCompatibilityVersion: 1 } )"

fi
