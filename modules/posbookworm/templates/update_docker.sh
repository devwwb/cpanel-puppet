#!/bin/bash
set -e

echo "## Update docker ###########################################################"

#update docker
apt-get install --reinstall docker-ce=5:28.1.1-1~debian.11~bookworm -y --allow-downgrades
service docker restart
