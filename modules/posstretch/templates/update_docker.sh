#!/bin/bash

echo "## Update docker ###########################################################"

#update docker
apt-get install --reinstall docker-ce=18.03.0~ce-0~debian -y
service docker restart
