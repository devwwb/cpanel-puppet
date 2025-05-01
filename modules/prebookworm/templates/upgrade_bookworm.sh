#!/bin/bash
set -e

echo "## Upgrade bookworm #########################################################"

#stop monit
service monit stop

export LC_ALL=C
apt -y update
apt-get clean
echo "## List slapd.d #########################################################"
ldapsearch -H ldapi:/// -Y external -s one -b 'dc=example,dc=tld'
echo "## Upgrade #########################################################"
apt -y upgrade
apt-get clean
echo "## List slapd.d #########################################################"
ldapsearch -H ldapi:/// -Y external -s one -b 'dc=example,dc=tld'
echo "## Full-upgrade #########################################################"
apt -y full-upgrade
apt-get clean
echo "## List slapd.d #########################################################"
ldapsearch -H ldapi:/// -Y external -s one -b 'dc=example,dc=tld'
echo "## List deleted packages to purge #########################################################"
apt list '~c'

