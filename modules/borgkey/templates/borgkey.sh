#!/bin/bash
#set -e

## params
url="ldapi://"
basedn="dc=example,dc=tld"
apiobject="ou=api,dc=example,dc=tld"
hostname=$(hostname)
email=root@$hostname
tokenbase64=`ldapsearch -Q -Y EXTERNAL -H "$url" -b "$apiobject" -s base | awk -F ":: " '$1 == "userPassword" {print $2}'`
host=`ldapsearch -Q -Y EXTERNAL -H "$url" -b "$apiobject" -s base | awk -F ": " '$1 == "host" {print $2}'`
apiurl="${host}/vm/${hostname}/"
token=`echo "$tokenbase64" | base64 --decode`

## conf
conf=$(curl -s $apiurl -X GET -H "Content-Type: application/json" -H "X-HOSTNAME: ${hostname}" -H "Authorization: Token ${token}")
enabled=$(echo "${conf}" | jq -r '.backup_enabled')

## backup
if [ $enabled == 'true' ]
then

  #backup vars
  server=$(echo "${conf}" | jq -r '.backup_server')
  port=$(echo "${conf}" | jq -r '.backup_port')
  user=$(echo "${conf}" | jq -r '.backup_user')

  #borg backup vars
  export BORG_RSH="ssh -i /root/.ssh/id_rsa_borgbackup"
  export BORG_PASSPHRASE=""

  #borg export key
  borg key export ssh://$user@$server:$port/./backup /etc/maadix/borgkey.ldif

  #copy key to ldap
  sed -i -e 's/^/ /' /etc/maadix/borgkey.ldif
  sed -i '1s/^/status:/' /etc/maadix/borgkey.ldif
  sed -i '1 i\replace: status' /etc/maadix/borgkey.ldif
  sed -i '1 i\changetype: modify' /etc/maadix/borgkey.ldif
  sed -i '1 i\dn: cn=borgbackup,ou=credentials,dc=example,dc=tld' /etc/maadix/borgkey.ldif
  ldapmodify -H ldapi:// -Y EXTERNAL -f /etc/maadix/borgkey.ldif
  rm /etc/maadix/borgkey.ldif

  #wait some minutes and delete key from ldap
  sleep 360
  ldapmodify -Q -Y EXTERNAL -H ldapi:/// << EOF
dn: cn=borgbackup,ou=credentials,dc=example,dc=tld
changetype: modify
replace: status
status: clean
EOF

fi
