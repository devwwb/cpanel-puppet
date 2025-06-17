#!/bin/bash

#get active groups
echo "## Active groups #############################################################"
echo ""
egroups=($(ldapsearch -Q -H ldapi:// -Y EXTERNAL -LLL -s one -b "ou=groups,dc=example,dc=tld" "(&(objectClass=*)(status=enabled)(type=available))" | grep ou: | sed "s|.*: \(.*\)|\1|"))
for i in "${egroups[@]}"
do
  echo "$i"
done
echo ""

#get inactive groups
egroups=($(ldapsearch -Q -H ldapi:// -Y EXTERNAL -LLL -s one -b "ou=groups,dc=example,dc=tld" "(&(objectClass=*)(status=disabled)(type=installed))" | grep ou: | sed "s|.*: \(.*\)|\1|"))
echo "## Inactive groups ###########################################################"
echo ""
for i in "${egroups[@]}"
do
  echo "$i"
done
echo ""

