#!/bin/bash

#read mysql password from ldap
dn="ou=password,ou=mysql,ou=groups,dc=example,dc=tld"
#try to decrypt password if gnupg kit is setup
if [[ -d /usr/share/mxcp/.gnupg ]]
then
  mysql=$(ldapsearch -o ldif-wrap=no -H ldapi:// -Y EXTERNAL -b "$dn" | grep status: | sed "s|.*: \(.*\)|\1|" | base64 -d | gpg --decrypt)
else
  mysql=$(ldapsearch -o ldif-wrap=no -H ldapi:// -Y EXTERNAL -b "$dn" | grep status: | sed "s|.*: \(.*\)|\1|" )
fi

#read adminuser from ldap
url="ldapi://"
basedn="dc=example,dc=tld"
adminuser=`ldapsearch -Q -Y EXTERNAL -H "$url" -b "$basedn" -s one "(&(objectclass=simpleSecurityObject)(status=active))" | awk -F ": " '$1 == "cn" {print $2}'`

## update mysql superuser
mysql <<EOF
SET PASSWORD FOR '$adminuser'@'localhost' = PASSWORD('$mysql');
EOF

#delete ldap password
ldapdelete -H ldapi:// -Y EXTERNAL "$dn"
