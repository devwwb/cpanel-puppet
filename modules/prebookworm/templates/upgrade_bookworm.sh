#!/bin/bash
set -e

echo "## Upgrade bookworm #########################################################"

#stop monit
service monit stop

#fix growroot
#doc: https://serverfault.com/a/1168110
if [ -f /usr/share/initramfs-tools/hooks/growroot ]; then
  mv /usr/share/initramfs-tools/hooks/growroot /root/growroot
  update-initramfs -u
fi

export LC_ALL=C
apt -y update
apt-get clean
echo "## List slapd.d #########################################################"
ldapsearch -H ldapi:/// -Y external -s base -b 'dc=example,dc=tld'
echo "## Upgrade #########################################################"
apt -y upgrade || mv /usr/share/initramfs-tools/hooks/growroot /root/growroot && update-initramfs -u && apt -y upgrade
apt-get clean
echo "## List slapd.d #########################################################"
ldapsearch -H ldapi:/// -Y external -s base -b 'dc=example,dc=tld'
echo "## Full-upgrade #########################################################"
apt -y full-upgrade
apt-get clean
echo "## List slapd.d #########################################################"
ldapsearch -H ldapi:/// -Y external -s base -b 'dc=example,dc=tld'
echo "## List deleted packages to purge #########################################################"
apt list '~c'

#fix growroot
if [ -f /root/growroot ]; then
  mv /root/growroot /usr/share/initramfs-tools/hooks/growroot
  update-initramfs -u
fi
