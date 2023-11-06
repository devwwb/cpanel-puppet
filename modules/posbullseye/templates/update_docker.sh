#!/bin/bash

echo "## Update docker ###########################################################"

#update docker
apt-get install --reinstall docker-ce=5:20.10.21~3-0~debian-bullseye -y --allow-downgrades
service docker restart
