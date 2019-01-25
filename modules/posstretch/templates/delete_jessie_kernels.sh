#!/bin/bash

echo "## Delete jessie kernels ###################################################"

#delete old jessie kernels
aptitude search '~o' -F '%p' | grep -v one-context | grep -v puppet-agent | xargs apt-get -y remove --purge
