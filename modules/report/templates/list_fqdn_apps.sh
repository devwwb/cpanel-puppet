#!/bin/bash

#get apps fqdns
fqdns=($(ldapsearch -H ldapi:// -Y EXTERNAL -b "ou=groups,dc=example,dc=tld" "(ou=domain)" | grep status | sed 's/status: //g'))
echo "## FQDN APPS #############################################################"
echo ""
for i in "${fqdns[@]}"
do
  echo "$i"
  dig +short "$i"
done
echo ""

