#!/bin/bash

echo "## Update easyrsa pki from v2 to v3 ###########################################################"

#doc: https://community.openvpn.net/openvpn/wiki/easyrsa-upgrade

##Backup /etc/openvpn/fqdn
sleep 30
DATE=`date +%Y-%m-%d`
FQDN=`hostname -f`
if [ ! -d /etc/maadix/backups ]; then
  mkdir /etc/maadix/backups
fi
sleep 2
cp -Rp /etc/openvpn/$FQDN /etc/maadix/backups/$FQDN-$DATE

##Download easyrsa-3.0.7 tha ships with upgrade script
cd /etc/openvpn/$FQDN
wget https://github.com/OpenVPN/easy-rsa/releases/download/v3.0.7/EasyRSA-3.0.7.tgz
tar -xvzf EasyRSA-3.0.7.tgz

##Copy files needed for the upgrade
cp -p EasyRSA-3.0.7/easyrsa easy-rsa/
cp -p /usr/share/easy-rsa/openssl-easyrsa.cnf easy-rsa/openssl-1.0.cnf
cp -p /usr/share/easy-rsa/openssl-easyrsa.cnf easy-rsa/
cp -Rp EasyRSA-3.0.7/x509-types easy-rsa/
cp -p EasyRSA-3.0.7/vars.example easy-rsa/

##Upgrade pki to version 3
cd easy-rsa
rm openssl.cnf
ln -s /etc/openvpn/$FQDN/easy-rsa/openssl-1.0.cnf openssl.cnf
#./easyrsa upgrade pki (confirm with 4 yes)
echo -e "yes\nyes\nyes\nyes" | ./easyrsa upgrade pki

##Replace old keys(pki) folder with new pki
rm -r keys
mv pki keys

##Move/copy and relink files
ln -s /etc/openvpn/$FQDN/easy-rsa/openssl-1.0.cnf openssl.cnf
cd keys
ln -s /etc/openvpn/$FQDN/crl.pem .
cp -p certs_by_serial/dh4096.pem dh.pem

#Clean
rm -r /etc/openvpn/$FQDN/easy-rsa/VERY-SAFE-PKI
rm /etc/openvpn/$FQDN/EasyRSA-3.0.7.tgz
