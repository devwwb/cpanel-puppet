#!/bin/bash
set -e

#backup etc
echo "## Backup etc ##########################################################"
if [ ! -d /home/.trash/backups ]; then
  mkdir /home/.trash/backups
fi
cd /home/.trash/backups
tar -czf etc_`date +%Y_%m_%d-%H_%M_%S`.tar.gz /etc
chmod 600 etc*

echo "## Backup ldap database ##########################################################"
#doc: https://openldap.org/doc/admin25/maintenance.html

#stop service before backup
service monit stop
service cron stop
service slapd stop

#backup mdb database
date=$(date +%Y_%m_%d-%H_%M_%S)
tar -czf ldap_data_${date}.tar.gz /var/lib/ldap/data.mdb
chmod 600 ldap_data_${date}.tar.gz

#backup example.tld domain
slapcat -F /etc/ldap/slapd.d -b dc=example,dc=tld -a "(&(entryDN:dnSubtreeMatch:=dc=example,dc=tld))" -l ldap_backup_${date}.ldif
chmod 600 ldap_backup_${date}.ldif

#purge ldap database
rm /var/lib/ldap/*

#rename database if required
if [ -f /etc/ldap/slapd.d/cn\=config/olcDatabase\=\{2\}mdb.ldif ]; then
  if grep -q 'dc=example,dc=tld' /etc/ldap/slapd.d/cn\=config/olcDatabase\=\{2\}mdb.ldif; then
    echo "## Rename ldap database ############################################"
    #delete unused database with number 1
    rm /etc/ldap/slapd.d/cn\=config/olcDatabase\=\{1\}mdb.ldif
    #save slapd.d conf
    slapcat -F /etc/ldap/slapd.d -n 0 -l ldap_config_${date}.ldif
    #clean slapd.d conf
    rm -r /etc/ldap/slapd.d/*
    #rename database in exported slapd.d conf
    sed -i -e 's/{2}mdb/{1}mdb/g' ldap_config_${date}.ldif
    #load slapd.d conf
    slapadd -F /etc/ldap/slapd.d -n 0 -l ldap_config_${date}.ldif
    #set perms
    chown -R openldap:openldap /etc/ldap/slapd.d
  fi
fi

#load data
echo "## Load ldap database ##########################################################"
service slapd start
slapadd -F /etc/ldap/slapd.d -l ldap_backup_${date}.ldif -b 'dc=example,dc=tld'

#reset slapd package debconf
echo PURGE | debconf-communicate slapd
echo "slapd slapd/no_configuration boolean true" | debconf-set-selections

#check
echo "## List slapd.d #########################################################"
ldapsearch -H ldapi:/// -Y external -s base -b 'dc=example,dc=tld'
