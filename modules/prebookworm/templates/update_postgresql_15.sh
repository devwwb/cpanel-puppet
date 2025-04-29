#!/bin/bash
set -e

#if postgresql version is 13
if apt-show-versions | grep postgresql-13; then

  echo "## Update postgresql to 15 ################################################"
  #doc https://blog.samuel.domains/blog/tutorials/from-stretch-to-bullseye-how-to-upgrade-a-9-6-postgresql-cluster-to-11

  #backup postgresql
  DATE=`date +%Y-%m-%d`
  if [ ! -d /home/.trash/backups ]; then
    mkdir /home/.trash/backups
  fi
  cd /tmp
  sudo -u postgres pg_dumpall > /home/.trash/backups/postgresql-$DATE.sql
  chmod 600 /home/.trash/backups/postgresql-$DATE.sql
  #to restore backup
  #sudo -u postgres psql -f BACKUP_FILE postgres

  #reindex databases
  sudo -u postgres reindexdb --all

  #update postgresql to 15
  apt-get install postgresql-15 postgresql-client-15 postgresql-server-dev-15 -y

  #update cluster to 15 and disable previous cluster
  #with workaround if there are client connections active
  #doc: https://gist.github.com/johanndt/6436bfad28c86b28f794
  pg_lsclusters
  sleep 10
  #drop empty new 15 cluster
  pg_dropcluster 15 main --stop
  pg_lsclusters
  sleep 5
  #stop 13 cluster
  pg_ctlcluster -m fast 13 main stop
  pg_lsclusters
  sleep 5
  #upgrade cluster 13 to 15
  pg_upgradecluster 13 main
  pg_lsclusters
  sleep 5
  service postgresql restart
  sleep 5
  service postgresql stop
  sleep 10
  #if upgrade succes
  if pg_lsclusters | grep -q 15; then
    #drop 13 cluster
    pg_dropcluster 13 main
    #purge old packages
    apt-get --purge remove postgresql-13 postgresql-client-13 -y
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


