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
    echo "waiting mongod 3.6"
    sleep 5
  done
  echo "mongod 3.6 running"
  ./backup.sh
  rm backup.sh
  echo "Backup mongodb databases:"
  ls -l dump/
fi

echo "## Update mongo to 4.0 #####################################################"
#if mongo version is 3.6
if mongod --version | grep v3.6; then

  #Upgrade MONGODB-CR to SCRAM
  mongo admin --host localhost --port 27017 --ssl --sslCAFile /opt/mongod/certs/rootCA.crt --eval "load('/root/.mongorc.js'); db.adminCommand({authSchemaUpgrade: 1})"

  #Set Compatibility version to 3.6
  mongo admin --host localhost --port 27017 --ssl --sslCAFile /opt/mongod/certs/rootCA.crt --eval "load('/root/.mongorc.js'); db.adminCommand( { setFeatureCompatibilityVersion: '3.6' } )"

  #update mongo repo for mongodb 4.0
  apt-key list | grep -C 5 mongo
  apt-key del '2930 ADAE 8CAF 5059 EE73  BB4B 5871 2A22 91FA 4AD5'
  curl 'https://pgp.mongodb.com/server-4.0.asc' | apt-key add -
  sed -i 's/3.6/4.0/g' /etc/apt/sources.list.d/mongodb.list

  #update mongodb to 4.0
  apt update
  apt install mongodb-org-{server,shell,tools} -y
  sleep 10
  service mongod restart

  #wait until mongod is up
  while ! nc -z localhost 27017; do
    echo "waiting mongod 4.0"
    sleep 1
  done
  echo "mongod 4.0 running"

  #setFeatureCompatibilityVersion to 4.0
  until mongo admin --host localhost --port 27017 --ssl --sslCAFile /opt/mongod/certs/rootCA.crt --eval "load('/root/.mongorc.js'); db.adminCommand( { getParameter: 1, featureCompatibilityVersion: 1 } )" | grep version | grep -v shell | grep -v server | grep 4.0
  do
    sleep 5
    echo "Trying to setFeatureCompatibilityVersion: '4.0'"
    mongo admin --host localhost --port 27017 --ssl --sslCAFile /opt/mongod/certs/rootCA.crt --eval "load('/root/.mongorc.js'); db.adminCommand( { setFeatureCompatibilityVersion: '4.0' } )"
  done

  #log
  mongo admin --host localhost --port 27017 --ssl --sslCAFile /opt/mongod/certs/rootCA.crt --eval "load('/root/.mongorc.js'); db.adminCommand( { getParameter: 1, featureCompatibilityVersion: 1 } )"

fi


echo "## Update mongo to 4.2 #####################################################"
#if mongo version is 4.0
if mongod --version | grep v4.0; then

  #update mongo repo for mongodb 4.2
  apt-key list | grep -C 5 mongo
  apt-key del '9DA3 1620 334B D75D 9DCB  49F3 6881 8C72 E525 29D4'
  curl 'https://pgp.mongodb.com/server-4.2.asc' | apt-key add -
  sed -i -E 's/4[.]0/4.2/g' /etc/apt/sources.list.d/mongodb.list

  #update mongodb to 4.2
  apt update
  apt install mongodb-org-{server,shell,tools} -y
  sleep 10
  service mongod restart

  #wait until mongod is up
  while ! nc -z localhost 27017; do
    echo "waiting mongod 4.2"
    sleep 1
  done
  echo "mongod 4.2 running"

  #setFeatureCompatibilityVersion to 4.2
  until mongo admin --host localhost --port 27017 --ssl --sslCAFile /opt/mongod/certs/rootCA.crt --eval "load('/root/.mongorc.js'); db.adminCommand( { getParameter: 1, featureCompatibilityVersion: 1 } )" | grep version | grep -v shell | grep -v server | grep 4.2
  do
    sleep 5
    echo "Trying to setFeatureCompatibilityVersion: '4.2'"
    mongo admin --host localhost --port 27017 --ssl --sslCAFile /opt/mongod/certs/rootCA.crt --eval "load('/root/.mongorc.js'); db.adminCommand( { setFeatureCompatibilityVersion: '4.2' } )"
  done

  #log
  mongo admin --host localhost --port 27017 --ssl --sslCAFile /opt/mongod/certs/rootCA.crt --eval "load('/root/.mongorc.js'); db.adminCommand( { getParameter: 1, featureCompatibilityVersion: 1 } )"

fi

#force certificate regeneration
if [ -f /etc/maadix/status/mongod-selfsigned-certs ]; then
  rm /etc/maadix/status/mongod-selfsigned-certs
fi
