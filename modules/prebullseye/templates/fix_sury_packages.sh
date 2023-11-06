#!/bin/bash

echo "## Fix sury packages ##################################################"

#override repo priorities, to allow downgrade sury packages to official packages versions
cat <<EOT >> /etc/apt/preferences.d/uninstall-deb.sury.org.pref
Package: *
Pin: release o=Debian
Pin-Priority: 1001

Package: *
Pin: release o=deb.sury.org
Pin-Priority: -1
EOT

apt install libxml2 -y --allow-downgrades
apt dist-upgrade -y --allow-downgrades

#restore repo priorities
rm /etc/apt/preferences.d/uninstall-deb.sury.org.pref
