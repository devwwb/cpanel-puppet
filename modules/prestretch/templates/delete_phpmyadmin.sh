#!/bin/bash

#delete phpmyadmin
mysql --defaults-extra-file=/root/.my.cnf -e "drop database phpmyadmin;"
mysql --defaults-extra-file=/root/.my.cnf -e "drop user phpmyadmin@localhost;"
apt-get remove --purge phpmyadmin -y


