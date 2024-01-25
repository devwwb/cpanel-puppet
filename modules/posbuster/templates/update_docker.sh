#!/bin/bash

echo "## Update docker ###########################################################"

#update docker
apt-get install --reinstall docker-ce=5:25.0.0-1~debian.10~buster -y --allow-downgrades
service docker restart
