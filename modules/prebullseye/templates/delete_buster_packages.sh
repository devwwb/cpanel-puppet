#!/bin/bash

echo "## Delete buster packages ##################################################"
#delete packages from buster with issues in the upgrade

#purge rkhunter
apt remove --purge rkhunter -y
