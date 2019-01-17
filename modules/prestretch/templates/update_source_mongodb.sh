#!/bin/bash

#update mongo repo for stretch
sed -i 's/3.4/3.6/g' /etc/apt/sources.list.d/mongodb.list
sed -i 's/jessie/stretch/g' /etc/apt/sources.list.d/mongodb.list

#import new key
cd /tmp
/usr/bin/curl -sLO https://www.mongodb.org/static/pgp/server-3.6.asc && sudo /usr/bin/apt-key add server-3.6.asc

