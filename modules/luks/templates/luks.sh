#!/bin/bash
#set -e

## params
url="ldapi://"
basedn="dc=example,dc=tld"
hostname=$(hostname)
fqdn=$(hostname -f)
email=root@$hostname
adminmail="admin@maadix.org"
date=$(date +%Y_%m_%d-%H_%M_%S)

#read luks passwords from ldap
declare -A LUKS
for value in luks0 luks1
do
  dn="ou=$value,ou=luks,ou=credentials,dc=example,dc=tld"
  #try to decrypt password if gnupg kit is setup
  if [[ -d /usr/share/mxcp/.gnupg ]]
  then
    LUKS[$value]=$(ldapsearch -o ldif-wrap=no -H ldapi:// -Y EXTERNAL -b "$dn" | grep status: | sed "s|.*: \(.*\)|\1|" | base64 -d | gpg --decrypt)
  else
    LUKS[$value]=$(ldapsearch -o ldif-wrap=no -H ldapi:// -Y EXTERNAL -b "$dn" | grep status: | sed "s|.*: \(.*\)|\1|" )
  fi
  #save luks keyfiles
  echo -n "${LUKS[$value]}" > /etc/maadix/$value
done

## CHECK

#check passphrase key-slot 0
cryptsetup luksOpen --key-file /etc/maadix/luksinit --test-passphrase --key-slot 0 /dev/vda2
test_exit=$?

#add new slot 1 before changing slot 0 if passphrase test is ok
if [ ${test_exit} -eq 0 ]; then
  echo "Test luks 0 / ok"
  cryptsetup luksAddKey --key-file /etc/maadix/luksinit --key-slot 1 /dev/vda2 /etc/maadix/luks1
  slot1_exit=$?

  #change slot 0 if slot 1 is created ok
  if [ ${slot1_exit} -eq 0 ]; then
    echo "Add luks 1 / ok"
    cryptsetup luksChangeKey --key-file /etc/maadix/luksinit --key-slot 0 /dev/vda2 /etc/maadix/luks0
    slot0_exit=$?

    #clean ldap and keyfiles
    if [ ${slot0_exit} -eq 0 ]; then
      echo "Change luks 0 / ok"
      for value in luks0 luks1
      do
        #delete ldap passwords
        dn="ou=$value,ou=luks,ou=credentials,dc=example,dc=tld"
        ldapdelete -H ldapi:// -Y EXTERNAL "$dn"
        #delete luks keyfiles
        rm /etc/maadix/$value
      done
      rm /etc/maadix/luksinit
      #send log
      #TODO
      #reboot
      sleep 10
      /lib/molly-guard/shutdown -r now
    fi

  fi
fi


