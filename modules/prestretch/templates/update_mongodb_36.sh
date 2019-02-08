#!/bin/bash

echo "## Update mongo to 3.6 #####################################################"

#restart mongod service
service mongod restart

#if mongo version is 3.4
if mongod --version | grep v3.4; then

  #setFeatureCompatibilityVersion to 3.6
  sleep 30
  mongo admin --port 27017 --eval "load('/root/.mongorc.js'); db.adminCommand( { setFeatureCompatibilityVersion: '3.6' } )"

fi
