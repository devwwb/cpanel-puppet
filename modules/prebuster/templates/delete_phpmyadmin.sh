#!/bin/bash

echo "## Delete phpmyadmin #######################################################"
#delete phpmyadmin
mysql --defaults-extra-file=/root/.my.cnf -e "drop database phpmyadmin;"
mysql --defaults-extra-file=/root/.my.cnf -e "drop user phpmyadmin@localhost;"
if apt-show-versions | grep phpmyadmin; then
  apt-get remove --purge phpmyadmin -y
fi


