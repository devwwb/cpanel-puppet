#!/bin/bash
set -e

#if postgresql version is 11
if pg_config --version | grep -q 11; then

  echo "## Update postgresql to 13 ################################################"
  #doc https://blog.samuel.domains/blog/tutorials/from-stretch-to-buster-how-to-upgrade-a-9-6-postgresql-cluster-to-11

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
  sudo -u postgres reindexdb --all

  #update postgresql to 13
  apt-get install postgresql-13 postgresql-client-13 postgresql-server-dev-13 -y

  #update cluster to 13 and disable previous cluster
  #with workaround if there are client connections active
  #doc: https://gist.github.com/johanndt/6436bfad28c86b28f794
  pg_lsclusters
  sleep 10
  #drop empty new 13 cluster
  pg_dropcluster 13 main --stop
  pg_lsclusters
  sleep 5
  #stop 11 cluster
  pg_ctlcluster -m fast 11 main stop
  pg_lsclusters
  sleep 5
  #upgrade cluster 11 to 13
  pg_upgradecluster 11 main
  pg_lsclusters
  sleep 5
  service postgresql restart
  sleep 5
  service postgresql stop
  sleep 10
  #if upgrade succes
  if pg_lsclusters | grep -q 13; then
    #drop 11 cluster
    pg_dropcluster 11 main
    #purge old packages
    apt-get --purge remove postgresql-11 postgresql-client-11 -y
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


