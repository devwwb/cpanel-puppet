#!/bin/bash

#restart mongod service
service mongod restart

#setFeatureCompatibilityVersion to 3.6
sleep 10
mongo admin --port 27017 --eval "load('/root/.mongorc.js'); db.adminCommand( { setFeatureCompatibilityVersion: '3.6' } )"
