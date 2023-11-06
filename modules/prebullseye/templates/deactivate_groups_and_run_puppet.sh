#!/bin/bash

#get enabled groups, excluding mail, mongo, nodejs, docker
egroups=($(ldapsearch -H ldapi:// -Y EXTERNAL -LLL -s one -b "ou=groups,dc=example,dc=tld" "(&(objectClass=*)(type=available)(status=enabled)(!(ou:dn:=mail)))" | grep -v nodejs | grep -v mongodb | grep -v docker | grep ou: | sed "s|.*: \(.*\)|\1|"))

#get hostname
hostname=`hostname`

#set cpanel to running
/etc/maadix/scripts/setrunningcpanel.sh

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


#run puppet only if there were active groups
if [ ${#egroups[@]} -eq 0 ]; then
    echo "## All groups are disabled, puppet doesn't run #############################"
    #exit script with 0
    exitscript=0
else
    echo "## Some groups enabled, run puppet without purging certs #########################################"
    /usr/local/bin/puppet agent --certname ${hostname}.maadix.org --test --skip_tags letsencrypt::certonly
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
fi

exit $exitscript
