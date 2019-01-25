#!/bin/bash

echo "## Update postgresql to 9.6 ################################################"

#if postgresql version is 9.4
if pg_config --version | grep 9.4; then


  #update postgresql to 9.6
  apt-get -t jessie-backports install postgresql-9.6 postgresql-client-9.6 postgresql-server-dev-9.6 -y

  #update cluster to 9.6 and disable previous cluster
  #with workaround if there are client connections active
  #doc: https://gist.github.com/johanndt/6436bfad28c86b28f794
  sleep 10
  pg_dropcluster 9.6 main --stop
  sleep 5
  pg_upgradecluster 9.4 main
  sleep 5
  service postgresql restart
  sleep 5
  service postgresql stop
  sleep 5
  pg_upgradecluster 9.4 main
  sleep 10
  pg_dropcluster 9.4 main
  sleep 10

  #purge old packages
  apt-get --purge remove postgresql-9.4 postgresql-client-9.4 postgresql-server-dev-9.4 -y

  #restart postgresql
  service postgresql restart

  #list clusters
  pg_lsclusters

fi


