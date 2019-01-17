#!/bin/bash

#update mongo repo form mongodb 3.4
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
