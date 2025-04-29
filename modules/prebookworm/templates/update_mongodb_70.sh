#!/bin/bash
set -e

echo "## Backup all mongodb databases ############################################"
apt install mongodb-org-tools -y --force-yes
apt install netcat -y
DATE=`date +%Y-%m-%d`
if [ ! -d /home/.trash/backups ]; then
  mkdir /home/.trash/backups
fi
if [ ! -d /home/.trash/backups/mongodb-$DATE ]; then
  echo "All databases"
  mkdir /home/.trash/backups/mongodb-$DATE
  cd /home/.trash/backups/mongodb-$DATE
  echo -n "mongodump --host localhost --port 27017 --ssl --sslCAFile /opt/mongod/certs/rootCA.crt -u admin -p " > backup.sh
  cat /etc/maadix/mongodbadmin | tr -d '\n' | sed "s@\\\\@@g" | tr -d \'\" >> backup.sh
  chmod +x backup.sh
  #wait until mongod is up
  while ! nc -z localhost 27017; do
    echo "waiting mongod 5.0"
    sleep 5
  done
  echo "mongod 5.0 running"
  ./backup.sh
  rm backup.sh
  echo "Backup mongodb databases:"
  ls -l dump/
fi

echo "## Update mongo to 6.0 #####################################################"
#if mongo version is 5.0
if mongod --version | grep version | grep 5.0; then

  #Set Compatibility version to 5.0
  mongosh admin --tls --tlsCAFile /opt/mongod/certs/rootCA.crt --host localhost --port 27017 --eval "load('/root/.mongoshrc.js'); db.adminCommand( { setFeatureCompatibilityVersion: '5.0' } )"

  #update mongo repo for mongodb 6.0
  wget -O /usr/share/keyrings/mongodb-server-6.0.asc -q https://www.mongodb.org/static/pgp/server-6.0.asc
  sed -i 's/5.0/6.0/g' /etc/apt/sources.list.d/mongodb.list

  #update mongodb to 6.0
  apt update
  service monit stop
  service mongod stop
  apt remove mongodb-org-database-tools-extra mongodb-org-tools -y
  apt install mongodb-org-{server,shell,tools,database-tools-extra}=6.0.22 -y --allow-downgrades
  sleep 10
  service mongod restart

  #wait until mongod is up
  while ! nc -z localhost 27017; do
    echo "waiting mongod 6.0"
    sleep 1
  done
  echo "mongod 6.0 running"

  #setFeatureCompatibilityVersion to 6.0
  until mongosh admin --tls --tlsCAFile /opt/mongod/certs/rootCA.crt --host localhost --port 27017 --eval "load('/root/.mongoshrc.js'); db.adminCommand( { getParameter: 1, featureCompatibilityVersion: 1 } )" | grep version | grep -v shell | grep -v server | grep 6.0
  do
    sleep 5
    echo "Trying to setFeatureCompatibilityVersion: '6.0'"
    mongosh admin --tls --tlsCAFile /opt/mongod/certs/rootCA.crt --host localhost --port 27017 --eval "load('/root/.mongoshrc.js'); db.adminCommand( { setFeatureCompatibilityVersion: '6.0' } )"
  done

  #log
  mongosh admin --tls --tlsCAFile /opt/mongod/certs/rootCA.crt --host localhost --port 27017 --eval "load('/root/.mongoshrc.js'); db.adminCommand( { getParameter: 1, featureCompatibilityVersion: 1 } )"

fi

echo "## Update mongo to 7.0 #####################################################"
#if mongo version is 6.0
if mongod --version | grep version | grep 6.0; then

  #Set Compatibility version to 6.0
  mongosh admin --tls --tlsCAFile /opt/mongod/certs/rootCA.crt --host localhost --port 27017 --eval "load('/root/.mongoshrc.js'); db.adminCommand( { setFeatureCompatibilityVersion: '6.0' } )"

  #update mongo repo for mongodb 7.0
  wget -O /usr/share/keyrings/mongodb-server-7.0.asc -q https://www.mongodb.org/static/pgp/server-7.0.asc
  sed -i 's/6.0/7.0/g' /etc/apt/sources.list.d/mongodb.list

  #update mongodb to 6.0
  apt update
  service monit stop
  service mongod stop
  apt remove mongodb-org-database-tools-extra mongodb-org-tools -y
  apt install mongodb-org-{server,shell,tools,database-tools-extra}=7.0.19 -y --allow-downgrades
  sleep 10
  service mongod restart

  #wait until mongod is up
  while ! nc -z localhost 27017; do
    echo "waiting mongod 7.0"
    sleep 1
  done
  echo "mongod 7.0 running"

  #setFeatureCompatibilityVersion to 7.0
  until mongosh admin --tls --tlsCAFile /opt/mongod/certs/rootCA.crt --host localhost --port 27017 --eval "load('/root/.mongoshrc.js'); db.adminCommand( { getParameter: 1, featureCompatibilityVersion: 1 } )" | grep version | grep -v shell | grep -v server | grep 7.0
  do
    sleep 5
    echo "Trying to setFeatureCompatibilityVersion: '7.0'"
    #add confirm: true. https://www.mongodb.com/docs/v7.0/reference/command/setFeatureCompatibilityVersion/
    mongosh admin --tls --tlsCAFile /opt/mongod/certs/rootCA.crt --host localhost --port 27017 --eval "load('/root/.mongoshrc.js'); db.adminCommand( { setFeatureCompatibilityVersion: '7.0', confirm: true } )"
  done

  #log
  mongosh admin --tls --tlsCAFile /opt/mongod/certs/rootCA.crt --host localhost --port 27017 --eval "load('/root/.mongoshrc.js'); db.adminCommand( { getParameter: 1, featureCompatibilityVersion: 1 } )"

fi
