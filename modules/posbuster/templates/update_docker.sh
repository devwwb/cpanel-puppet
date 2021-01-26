#!/bin/bash

echo "## Update docker ###########################################################"

#update docker
apt-get install --reinstall docker-ce=5:19.03.2~3-0~debian-buster -y --allow-downgrades
service docker restart
