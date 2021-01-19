#!/bin/bash

echo "## Update postgresql to 11 ################################################"
#doc https://blog.samuel.domains/blog/tutorials/from-stretch-to-buster-how-to-upgrade-a-9-6-postgresql-cluster-to-11

#if postgresql version is 9.6
if pg_config --version | grep -q 9.6; then

  #backup postgresql
  DATE=`date +%Y-%m-%d`
  if [ ! -d /etc/maadix/backups ]; then
    mkdir /etc/maadix/backups
  fi
  cd /tmp
  sudo -u postgres pg_dumpall > /etc/maadix/backups/postgresql-$DATE.sql
  #to restore backup
  #sudo -u postgres psql -f BACKUP_FILE postgres

  #reindex databases
  reindexdb --all

  #update postgresql to 11
  apt-get install postgresql-11 postgresql-client-11 postgresql-server-dev-11 -y

  #update cluster to 11 and disable previous cluster
  #with workaround if there are client connections active
  #doc: https://gist.github.com/johanndt/6436bfad28c86b28f794
  pg_lsclusters
  sleep 10
  #drop empty new 11 cluster
  pg_dropcluster 11 main --stop
  pg_lsclusters
  sleep 5
  #stop 9.6 cluster
  pg_ctlcluster -m fast 9.6 main stop
  pg_lsclusters
  sleep 5
  #upgrade cluster 9.6 to 11
  pg_upgradecluster 9.6 main
  pg_lsclusters
  sleep 5
  service postgresql restart
  sleep 5
  service postgresql stop
  sleep 5
  pg_upgradecluster 9.6 main
  sleep 10
  #if upgrade succes
  if pg_lsclusters | grep -q 11; then
    #drop 9.6 cluster
    pg_dropcluster 9.6 main
    #purge old packages
    apt-get --purge remove postgresql-9.6 postgresql-client-9.6 postgresql-server-dev-9.6 -y
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


