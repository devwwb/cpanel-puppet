#!/bin/bash

#get deactivated groups, excluding mail, mongo, nodejs, docker
egroups=($(ldapsearch -H ldapi:// -Y EXTERNAL -LLL -s one -b "ou=groups,dc=example,dc=tld" "(&(objectClass=*)(status=disabled)(type=installed))" | grep -v mail | grep -v nodejs | grep -v mongodb | grep -v docker | grep ou: | sed "s|.*: \(.*\)|\1|"))

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
