#!/bin/bash

#get active groups
egroups=($(ldapsearch -H ldapi:// -Y EXTERNAL -LLL -s one -b "ou=groups,dc=example,dc=tld" "(&(objectClass=*)(status=enabled)(type=available))" | grep ou: | sed "s|.*: \(.*\)|\1|"))
echo "## Active groups #############################################################"
echo ""
for i in "${egroups[@]}"
do
  echo "$i"
done
echo ""

#get inactive groups
egroups=($(ldapsearch -H ldapi:// -Y EXTERNAL -LLL -s one -b "ou=groups,dc=example,dc=tld" "(&(objectClass=*)(status=disabled)(type=installed))" | grep ou: | sed "s|.*: \(.*\)|\1|"))
echo "## Inactive groups ###########################################################"
echo ""
for i in "${egroups[@]}"
do
  echo "$i"
done
echo ""

