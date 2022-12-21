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
  port=$(echo "${conf}" | jq -r '.backup_port')
  server=$(echo "${conf}" | jq -r '.backup_server')
  user=$(echo "${conf}" | jq -r '.backup_user')
  server2=$(echo "${conf}" | jq -r '.backup_secondary_server // empty')
  user2=$(echo "${conf}" | jq -r '.backup_secondary_user // empty')

  #borg backup vars
  export BORG_RSH="ssh -i /root/.ssh/id_rsa_borgbackup"
  export BORG_PASSPHRASE=""

  #borg export keys
  borg key export ssh://$user@$server:$port/./backup /etc/maadix/borgkey
  if [ ! -z "$server2" ] && [ ! -z "$user2" ]; then
    borg key export ssh://$user2@$server2:$port/./backup /etc/maadix/borgkey2
  fi

  #add repo info
  { echo "REPO ssh://$user@$server:$port/./backup KEYFILE:"; 
    echo "-------------------------------------------------------------------------"; 
    cat /etc/maadix/borgkey; } > /etc/maadix/borgkeymix
  if [ ! -z "$server2" ] && [ ! -z "$user2" ]; then
      echo "" >> /etc/maadix/borgkeymix
    { echo "REPO ssh://$user2@$server2:$port/./backup KEYFILE:"; 
      echo "-------------------------------------------------------------------------"; 
      cat /etc/maadix/borgkey2; } >> /etc/maadix/borgkeymix
  fi

  #convert to base64
  cat /etc/maadix/borgkeymix | base64 > /etc/maadix/borgkeymix.ldif

  #copy key to ldap
  sed -i -e 's/^/ /' /etc/maadix/borgkeymix.ldif
  sed -i '1s/^/status::/' /etc/maadix/borgkeymix.ldif
  sed -i '1 i\replace: status' /etc/maadix/borgkeymix.ldif
  sed -i '1 i\changetype: modify' /etc/maadix/borgkeymix.ldif
  sed -i '1 i\dn: cn=borgbackup,ou=credentials,dc=example,dc=tld' /etc/maadix/borgkeymix.ldif
  ldapmodify -H ldapi:// -Y EXTERNAL -f /etc/maadix/borgkeymix.ldif
  rm -f /etc/maadix/borgkey
  rm -f /etc/maadix/borgkey2
  rm -f /etc/maadix/borgkeymix
  rm -f /etc/maadix/borgkeymix.ldif

  #set type to available in ldap to inform mxcp that the key is present
  ldapmodify -Q -Y EXTERNAL -H ldapi:/// << EOF
dn: cn=borgbackup,ou=credentials,dc=example,dc=tld
changetype: modify
replace: type
type: available
EOF

  #wait some minutes and delete key from ldap
  sleep 360
  ldapmodify -Q -Y EXTERNAL -H ldapi:/// << EOF
dn: cn=borgbackup,ou=credentials,dc=example,dc=tld
changetype: modify
replace: status
status: clean
EOF

  #set type to pending in ldap to inform mxcp that the key is not present
  ldapmodify -Q -Y EXTERNAL -H ldapi:/// << EOF
dn: cn=borgbackup,ou=credentials,dc=example,dc=tld
changetype: modify
replace: type
type: pending
EOF

fi
