#!/bin/bash

#update mongodb to 9.6
apt-get -t jessie-backports install postgresql-9.6 postgresql-client-9.6 postgresql-server-dev-9.6 -y

#update cluster to 9.6 and disable previous cluster
sleep 10
pg_dropcluster 9.6 main --stop
sleep 10
pg_upgradecluster 9.4 main
sleep 10
pg_dropcluster 9.4 main
sleep 10

#purge old packages
apt-get --purge remove postgresql-9.4 postgresql-client-9.4 postgresql-server-dev-9.4 -y

#restart postgresql
service postgresql restart
