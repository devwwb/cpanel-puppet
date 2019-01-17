#!/bin/bash

#delete onlyoffice docker image
docker rmi -f $(docker images | grep onlyoffice/documentserver | awk '{ print $3 }')
