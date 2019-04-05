#!/bin/bash

echo "## Update classifier #######################################################" 

#update default_groups array in classifier.yaml and set defaults for jessie
sed -i 's/default_groups.*/default_groups: [mysql,apache,apache-php-mod,ldap,mail,cpanel,pamldap,passwd]/' /etc/facter/facts.d/classifier.yaml
