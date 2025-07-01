#!/bin/bash
set -e

echo "## Upgrade bullseye ##########################################################"

#upgrade bullseye
apt -y update
apt -y upgrade
apt -y full-upgrade
if [[ -n $(find /etc/ -name '*.dpkg-new') ]]; then
  find /etc/ -name '*.dpkg-new' | xargs rm
fi
if [[ -n $(find /etc/ -name '*.dpkg-old') ]]; then
  find /etc/ -name '*.dpkg-old' | xargs rm
fi

#clean configurations
if [[ -n $(find /etc -name '*.dpkg-*' -o -name '*.ucf-*' -o -name '*.merge-error') ]]; then
  find /etc -name '*.dpkg-*' -o -name '*.ucf-*' -o -name '*.merge-error' | xargs rm
fi

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
apt install apt-forktracer -y
apt-forktracer | sort

#dpkg audit
echo "## Dpkg audit ##########################################################"
dpkg --audit

#install gpgv
apt -y install gpgv
