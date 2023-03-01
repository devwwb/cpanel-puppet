#!/bin/bash

#params
DOMAIN=$1
WEBROOT=$4
VHOSTUSER=$2
VHOSTGROUP=$3
BASEDN="vd=$1,o=hosting,dc=example,dc=tld"
DBPASS=`pwgen -c -1 20`
ADMINMAIL=`ldapsearch -Q -Y EXTERNAL -H ldapi:// -b 'dc=example,dc=tld' -s one "(&(objectclass=simpleSecurityObject)(status=active))" | awk -F ": " '$1 == "email" {print $2}'`
ADMINUSER=`ldapsearch -Q -Y EXTERNAL -H ldapi:// -b 'dc=example,dc=tld' -s one "(&(objectclass=simpleSecurityObject)(status=active))" | awk -F ": " '$1 == "cn" {print $2}'`

#failed mail params
SUBJECT="Maadix: Error instalación Wordpress / Wordpress install failed"
read -r -d '' BODY << EOM
[ES] English below

Hola,
La instalación del Worpdress en el dominio $DOMAIN no se ha podido completar debido a que la carpeta $WEBROOT contiene archivos. Para evitar perdida de datos se ha interrumpido el proceso.

Para poder instalar Wordpress asegúrate que la carpeta $WEBROOT esté vacía borrando o moviendo los archivos que contiene y luego vuelve a lanzar la instalación.

Tu Sistema Automatizado

[EN]

Hello,
The Worpdress installation at $DOMAIN could not be completed due to the fact that the $WEBROOT folder contains files. To avoid data loss the process has been interrupted.

To be able to install Wordpress make sure that the $WEBROOT folder is empty by deleting or moving the files it contains and then relaunch the installation.

Your Automated System

EOM

#check pass is present
ldapsearch -o ldif-wrap=no -H ldapi:// -Y EXTERNAL -s base -b "ou=password,ou=cms,$BASEDN" | grep status:
if [ $? -eq 0 ]; then
  #read admin user password from ldap
  #try to decrypt password if gnupg kit is setup
  if [[ -d /usr/share/mxcp/.gnupg ]]
  then
    ADMINPASS=$(ldapsearch -o ldif-wrap=no -H ldapi:// -Y EXTERNAL -s base -b "ou=password,ou=cms,$BASEDN" | grep status: | sed "s|.*: \(.*\)|\1|" | base64 -d | gpg --decrypt)
  else
    ADMINPASS=$(ldapsearch -o ldif-wrap=no -H ldapi:// -Y EXTERNAL -s base -b "ou=password,ou=cms,$BASEDN" | grep status: | sed "s|.*: \(.*\)|\1|" )
  fi
else
  #no password, exit
  exit 0
fi

#check dbname is present
ldapsearch -o ldif-wrap=no -H ldapi:// -Y EXTERNAL -s base -b "ou=cms,$BASEDN" | grep note:
if [ $? -eq 0 ]; then
  DBNAME=$(ldapsearch -o ldif-wrap=no -H ldapi:// -Y EXTERNAL -s base -b "ou=cms,$BASEDN" | grep note: | sed "s|.*: \(.*\)|\1|" | tr '-' '_')
else
  #no db, exit
  exit 0
fi

#check webroot exists
if [ -d "$WEBROOT" ]; then
  echo "Installing wp in ${WEBROOT}"
else
  echo "Error: ${WEBROOT} not found"
  exit 0
fi

#check dir is empty
DIRCOUNT=$(ls -1A $WEBROOT |wc -l)
if [ $DIRCOUNT -ne 0 ]; then

  #not empty, delete pass, set as failed, notify and exit
  ldapmodify -Q -Y EXTERNAL -H ldapi:/// << EOF
dn: ou=cms,$BASEDN
changetype: modify
replace: status
status: failed
EOF

  #delete ldap password
  ldapdelete -H ldapi:// -Y EXTERNAL "ou=password,ou=cms,$BASEDN"

  #send mail
  echo -e "$BODY" | mail -s "$SUBJECT" $ADMINMAIL

  exit 0
fi

#create database
if [ -f /root/.my.cnf ]; then
    mysql --defaults-extra-file=/root/.my.cnf -e "CREATE DATABASE $DBNAME;"
    mysql --defaults-extra-file=/root/.my.cnf -e "CREATE USER $DBNAME@localhost IDENTIFIED BY '$DBPASS';"
    mysql --defaults-extra-file=/root/.my.cnf -e "GRANT ALL PRIVILEGES ON $DBNAME.* TO '$DBNAME'@'localhost';"
    mysql --defaults-extra-file=/root/.my.cnf -e "FLUSH PRIVILEGES;"
fi


#setup wp
cd $WEBROOT
pwd
sudo -u $VHOSTUSER wp core download
sudo -u $VHOSTUSER wp config create --dbname=$DBNAME --dbuser=$DBNAME --dbpass=$DBPASS --extra-php <<PHP
define('FS_METHOD','direct');
PHP
sudo -u $VHOSTUSER wp core install --url=$DOMAIN --title=$DOMAIN --admin_user=$ADMINUSER --admin_password=$ADMINPASS --admin_email=$ADMINMAIL

#wp default conf
#sudo -u $VHOSTUSER wp option update permalink_structure '/%postname%'
sudo -u $VHOSTUSER wp option update default_pingback_flag ""
sudo -u $VHOSTUSER wp option update default_ping_status ""
sudo -u $VHOSTUSER wp option update default_comment_status ""
sudo -u $VHOSTUSER wp config set DISALLOW_FILE_EDIT true --raw
cat > wp-content/uploads/.htaccess << ENDOFFILE
<Files *.php>
deny from all
</Files>
ENDOFFILE

#permissions
cd $WEBROOT
chmod -R 770 *
chown -R $VHOSTUSER:$VHOSTGROUP * -R

#set installed in ldap
ldapmodify -Q -Y EXTERNAL -H ldapi:/// << EOF
dn: ou=cms,$BASEDN
changetype: modify
replace: status
status: enabled
EOF

#delete ldap password
ldapdelete -H ldapi:// -Y EXTERNAL "ou=password,ou=cms,$BASEDN"

echo "WP installed with DOMAIN:$DOMAIN WEBROOT:$WEBROOT VHOSTUSER:$VHOSTUSER VHOSTGROUP:$VHOSTGROUP DBNAME:$DBNAME"


