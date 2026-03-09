#!/bin/bash


#get hostname
hostname=`hostname`

#set cpanel to running
/etc/maadix/scripts/setrunningcpanel.sh


#get groups to install and disabled them, excluding mail, mongo, nodejs, docker
igroups=($(ldapsearch -H ldapi:// -Y EXTERNAL -LLL -s one -b "ou=groups,dc=example,dc=tld" "(&(objectClass=*)(type=available)(status=install)(!(ou:dn:=mail)))" | grep -v nodejs | grep -v mongodb | grep -v docker | grep ou: | sed "s|.*: \(.*\)|\1|"))

echo "## Deactivate groups marked to install #################################################"
#deactivate groups
for i in "${igroups[@]}"
do
echo "dn: ou=$i,ou=groups,dc=example,dc=tld
changetype:modify
replace:status
status: disabled" | ldapmodify -H ldapi:// -Y EXTERNAL
done

#get enabled groups, excluding mail, mongo, nodejs, docker
egroups=($(ldapsearch -H ldapi:// -Y EXTERNAL -LLL -s one -b "ou=groups,dc=example,dc=tld" "(&(objectClass=*)(type=available)(status=enabled)(!(ou:dn:=mail)))" | grep -v nodejs | grep -v mongodb | grep -v docker | grep ou: | sed "s|.*: \(.*\)|\1|"))

echo "## Deactivate enabled groups #################################################"
#deactivate groups
for i in "${egroups[@]}"
do
echo "dn: ou=$i,ou=groups,dc=example,dc=tld
changetype:modify
replace:type
type: upgrade
-
replace:status
status: disabled" | ldapmodify -H ldapi:// -Y EXTERNAL
done


#run puppet allways
echo "## Run puppet to update vm to latest conf without purging certs #########################################"
service monit stop
/usr/bin/choom -n -1000 -- /usr/local/bin/puppet agent --certname ${hostname}.maadix.org --test --skip_tags letsencrypt::certonly,rkhunter
# --test option implies --detailed-exitcodes. and Exitcode of 2 means that The run succeeded, and some resources were changed
#get puppet exit code
puppetexit=$?
#if puppet exit is 2, the script must exit with 0, else with 1
if [ $puppetexit -eq 2 ]; then
  exitscript=0
else
  #if puppet fails, unlock cpanel and exit 1
  /etc/init.d/setreadycpanel start
  exitscript=1
fi

exit $exitscript
