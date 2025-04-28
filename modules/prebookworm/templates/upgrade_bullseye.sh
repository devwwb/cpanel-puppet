#!/bin/bash
set -e

echo "## Upgrade bullseye ##########################################################"

#backup etc
if [ ! -d "/etc/maadix/backups" ]; then
  mkdir /etc/maadix/backups
fi
cp -Rp /etc /etc/maadix/backups/

#upgrade bullseye
apt -y update
apt -y upgrade
apt -y full-upgrade
find /etc/ -name '*.dpkg-new' | xargs rm
find /etc/ -name '*.dpkg-old' | xargs rm

#clean configurations
find /etc -name '*.dpkg-*' -o -name '*.ucf-*' -o -name '*.merge-error' | xargs rm

#delete apt pinning
if [ -f /etc/apt/preferences.d/90prosody ]; then
  rm /etc/apt/preferences.d/90prosody
fi
if [ -f /etc/apt/preferences.d/backports.pref ]; then
  rm /etc/apt/preferences.d/backports.pref
fi

#list obsolete packages
echo "## Obsolete packages ##########################################################"
apt list '~o'

#list non-debain packages
echo "## Non-debain packages ##########################################################"
apt-forktracer | sort

#dpkg audit
echo "## Dpkg audit ##########################################################"
dpkg --audit

#install gpgv
apt -y install gpgv
