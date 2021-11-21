#!/bin/bash

#array of keys in keyring
keyringkeys=( $(sudo -u zeyple gpg --homedir /var/lib/zeyple/keys -k --with-colons | awk -F: '$1 == "pub" { print $5 }') )

#array of keys in ldap
ldapkeys=( $(ldapsearch -LLL -o ldif-wrap=no -H ldapi:// -Y EXTERNAL -b 'ou=GnuPGKeys,dc=example,dc=tld' pgpCertID | grep pgpCertID | sed -ne 's/^pgpCertID: //p') )

#debug
echo "keyringkeys:"
for i in "${keyringkeys[@]}"
do
   echo "$i"
done
echo "ldapkeys:"
for i in "${ldapkeys[@]}"
do
   echo "$i"
done

#get uniq values. only in ldap or keyring
uniqkeys=( $(echo ${keyringkeys[@]} ${ldapkeys[@]} | tr ' ' '\n' | sort | uniq -u) )

#debug
echo "uniqkeys:"
for i in "${uniqkeys[@]}"
do
   echo "$i"
done

#form uniq values delete keys from keyring not in ldap and add new keys in ldap to keyring
for i in "${uniqkeys[@]}"
do
  if [[ " ${keyringkeys[*]} " =~ " ${i} " ]]; then
    echo "deleting key $i"
    sudo -u zeyple gpg --homedir /var/lib/zeyple/keys --batch --yes --delete-keys $i
  fi
  if [[ " ${ldapkeys[*]} " =~ " ${i} " ]]; then
    echo "adding key $i"
    sudo -u zeyple gpg --homedir /var/lib/zeyple/keys --recv-keys $i
  fi
done

#update keyringkeys array
keyringkeys=( $(sudo -u zeyple gpg --homedir /var/lib/zeyple/keys -k --with-colons | awk -F: '$1 == "pub" { print $5 }') )

#debug
echo "keyringkeys:"
for i in "${keyringkeys[@]}"
do
   echo "$i"
done
echo "ldapkeys:"
for i in "${ldapkeys[@]}"
do
   echo "$i"
done

#refresh keys from ldap if keys have been updated and resend all keys to keyserver to update all ldap fields
for i in "${keyringkeys[@]}"
do
   echo "refreshing key in keyring and updating key $i fields in ldap"
   sudo -u zeyple gpg --homedir /var/lib/zeyple/keys --recv-keys $i
   sudo -u zeyple gpg --homedir /var/lib/zeyple/keys --send-keys $i
done
