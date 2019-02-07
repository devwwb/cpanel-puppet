#!/bin/bash

echo "## Update postgresql to 9.6 ################################################"

#if postgresql version is 9.4
if pg_config --version | grep -q 9.4; then

  #backup postgresql
  DATE=`date +%Y-%m-%d`
  mkdir /etc/maadix/backups
  cd /tmp
  sudo -u postgres pg_dumpall > /etc/maadix/backups/postgresql-$DATE.sql
  #to restore backup
  #sudo -u postgres psql -f BACKUP_FILE postgres

  #update postgresql to 9.6
  apt-get -t jessie-backports install postgresql-9.6 postgresql-client-9.6 postgresql-server-dev-9.6 -y

  #update cluster to 9.6 and disable previous cluster
  #with workaround if there are client connections active
  #doc: https://gist.github.com/johanndt/6436bfad28c86b28f794
  pg_lsclusters
  sleep 10
  #drop empty new 9.6 cluster
  pg_dropcluster 9.6 main --stop
  pg_lsclusters
  sleep 5
  #stop 9.4 cluster
  pg_ctlcluster -m fast 9.4 main stop
  pg_lsclusters
  sleep 5
  #upgrade cluster 9.4 to 9.6
  pg_upgradecluster 9.4 main
  pg_lsclusters
  sleep 5
  service postgresql restart
  sleep 5
  service postgresql stop
  sleep 5
  pg_upgradecluster 9.4 main
  sleep 10
  #if upgrade succes
  if pg_lsclusters | grep -q 9.6; then
    #drop 9.4 cluster
    pg_dropcluster 9.4 main
    #purge old packages
    apt-get --purge remove postgresql-9.4 postgresql-client-9.4 postgresql-server-dev-9.4 -y
    #restart postgresql
    service postgresql restart
    #list clusters
    pg_lsclusters
    exit 0
  else
    #list clusters
    pg_lsclusters
    exit 1
  fi

else
  exit 0
fi


