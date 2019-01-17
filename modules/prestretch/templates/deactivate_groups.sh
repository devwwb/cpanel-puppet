#!/bin/bash

#get enabled groups, excluding mail, mongo, nodejs, docker
egroups=($(ldapsearch -H ldapi:// -Y EXTERNAL -LLL -s one -b "ou=groups,dc=example,dc=tld" "(&(objectClass=*)(status=enabled)(!(ou:dn:=mail)))" | grep -v nodejs | grep -v mongodb | grep -v docker | grep ou: | sed "s|.*: \(.*\)|\1|"))

for i in "${egroups[@]}"
do
echo "dn: ou=$i,ou=groups,dc=example,dc=tld
changetype:modify
replace:type
type: installed
-
replace:status
status: disabled" | ldapmodify -H ldapi:// -Y EXTERNAL
done
