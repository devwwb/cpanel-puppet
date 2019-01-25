#!/bin/bash

#restart mongod service
service mongod restart

#if mongo version is 3.4
if mongod --version | grep v3.4; then

  echo "## Update mongo to 3.6 ##################################"

  #setFeatureCompatibilityVersion to 3.6
  sleep 10
  mongo admin --port 27017 --eval "load('/root/.mongorc.js'); db.adminCommand( { setFeatureCompatibilityVersion: '3.6' } )"

fi
