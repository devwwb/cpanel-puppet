#!/bin/bash

#add init script
echo "#!/bin/bash
cd /usr/share/cpanel-puppet
export FACTERLIB='./facts'
FACTER_posstretch=true puppet apply --modulepath ./modules manifests/site.pp
rm /etc/rc2.d/S99stretch
rm /etc/init.d/stretch" > /etc/init.d/stretch

#add to rc2
chmod +x /etc/init.d/stretch
ln -s /etc/init.d/stretch /etc/rc2.d/S99stretch
