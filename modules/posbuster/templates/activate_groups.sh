#!/bin/bash

echo "## Activate all groups #####################################################"

#get prebuster enabled groups, excluding mail, mongo, nodejs, docker
egroups=($(ldapsearch -H ldapi:// -Y EXTERNAL -LLL -s one -b "ou=groups,dc=example,dc=tld" "(&(objectClass=*)(status=disabled)(type=upgrade))" | grep ou: | sed "s|.*: \(.*\)|\1|"))
#get deactivated groups, excluding mail, mongo, nodejs, docker
dgroups=($(ldapsearch -H ldapi:// -Y EXTERNAL -LLL -s one -b "ou=groups,dc=example,dc=tld" "(&(objectClass=*)(status=disabled)(type=installed))" | grep ou: | sed "s|.*: \(.*\)|\1|"))

#activate prebuster enabled groups
for i in "${egroups[@]}"
do
echo "dn: ou=$i,ou=groups,dc=example,dc=tld
changetype:modify
replace:type
type: available
-
replace:status
status: enabled" | ldapmodify -H ldapi:// -Y EXTERNAL
done

#activate deactivated groups
for i in "${dgroups[@]}"
do
echo "dn: ou=$i,ou=groups,dc=example,dc=tld
changetype:modify
replace:type
type: installed
-
replace:status
status: enabled" | ldapmodify -H ldapi:// -Y EXTERNAL
done
