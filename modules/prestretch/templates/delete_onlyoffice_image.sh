#!/bin/bash

echo "## Delete onlyoffice image #################################################"
#if onlyoffice image exists
if docker images | grep onlyoffice/documentserver; then

  #delete onlyoffice docker image
  docker rmi -f $(docker images | grep onlyoffice/documentserver | awk '{ print $3 }')

fi
