#!/bin/bash

cd /usr/share/cpanel-puppet
export FACTERLIB="./facts"

for i in opendkim reboot customfqdn prestretch posstretch report cleanapt cleandocker samhainreset samhaincheck domains trash prebuster posbuster mysql rkhunter tally fail2ban zeyple borgbackup borgkey luks prebullseye posbullseye
do
  puppet="FACTER_$i=true puppet apply --noop --modulepath ./modules:/etc/puppetlabs/code/environments/production/modules manifests/site.pp"
  echo "$puppet"
  eval $puppet
done
