#!/bin/bash

echo "## Purge nodejs packages ###################################################"
#purge nodejs packages
apt-get remove --purge nodejs nodejs-dbg -y
