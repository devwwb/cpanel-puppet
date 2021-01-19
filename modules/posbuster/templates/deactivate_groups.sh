#!/bin/bash

echo "## Deactivate deactivates groups ###########################################"

#get deactivated groups, excluding mail, mongo, nodejs, docker
dgroups=($(ldapsearch -H ldapi:// -Y EXTERNAL -LLL -s one -b "ou=groups,dc=example,dc=tld" "(&(objectClass=*)(status=enabled)(type=installed))" | grep ou: | sed "s|.*: \(.*\)|\1|"))

#deactivate deactivated groups
for i in "${dgroups[@]}"
do
echo "dn: ou=$i,ou=groups,dc=example,dc=tld
changetype:modify
replace:type
type: installed
-
replace:status
status: disabled" | ldapmodify -H ldapi:// -Y EXTERNAL
done
