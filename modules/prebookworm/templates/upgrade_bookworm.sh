#!/bin/bash
set -e

echo '## Update apt keys'
#nginx
/usr/bin/apt-key adv --no-tty --keyserver keyserver.ubuntu.com --recv-keys 2FD21310B49F6B46

echo "## Upgrade bookworm #########################################################"

#stop monit
service monit stop

export LC_ALL=C
apt -y update
apt-get clean

echo "## List slapd.d #########################################################"
ldapsearch -H ldapi:/// -Y external -s base -b 'dc=example,dc=tld'

#fix growroot
#doc: https://serverfault.com/a/1168110
if dpkg -l cloud-initramfs-growroot; then
  echo "## Upgrade kernel first if cloud is present to fix growroot #########################################################"
  apt install -y linux-image-amd64 cloud-initramfs-growroot initramfs-tools initramfs-tools-core || mv /usr/share/initramfs-tools/hooks/growroot /root/growroot && update-initramfs -u && apt install -y linux-image-amd64 cloud-initramfs-growroot initramfs-tools initramfs-tools-core
fi

echo "## Upgrade #########################################################"
apt -y upgrade
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

#fix growroot end
if [ -f /root/growroot ]; then
  mv /root/growroot /usr/share/initramfs-tools/hooks/growroot
  update-initramfs -u
fi
