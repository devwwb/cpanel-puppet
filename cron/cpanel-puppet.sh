#!/bin/bash

##### Config ###############################

url="ldapi://"
basedn="dc=example,dc=tld"
cpanelobject="ou=cpanel,dc=example,dc=tld"
apiobject="ou=api,dc=example,dc=tld"
cpaneldn="ou=cpanel"
lockattribute="status"
releaseattribute="type"
timestampattribute="creationDate"
statusattribute="status"
groupsdn="ou=groups,dc=example,dc=tld"
timestamp=$(date +%s)
date=$(date -u +"%Y-%m-%d-%T")
hostname=$(hostname)
logdir="/etc/maadix/logs"
logmail="maadix@wwb.cc"

##### Functions ###############################

function setlockstatus ()
{
#echo "$1"
#echo "$2"
ldapmodify -Q -Y EXTERNAL -H "$url"  << EOF
dn: ou=$1,$cpanelobject
changetype: modify
replace: $lockattribute
$lockattribute: $2

EOF
}

##### Tasks ###############################

## Check puppet process

# If puppet apply process exists, exit
if [[ $(pgrep -f "puppet apply") ]]; then
  papply=`pgrep -f "puppet apply"`
  echo "Puppet apply is running with pid $papply, exit"
  exit 1
fi

# If puppet agent process exists, exit
if [[ $(pgrep -f "puppet agent") ]]; then
  pagent=`pgrep -f "puppet agent"`
  echo "Puppet agent is running with pid $pagent, exit"
  exit 1
fi

## If release is new, continue, because there are pending changes for local puppet in current release that must by applied before release update

# Get release
#release=`ldapsearch -Q -Y EXTERNAL -H "$url" -b "$basedn" "$cpaneldn" | awk -F ": " '$1 == "'"$releaseattribute"'" {print $2}'`
#echo "$release"

# Get repo branch
#branch=$(git branch | sed -n -e 's/^\* \(.*\)/\1/p')
#echo "$branch"


# Search if any of the modules is running (obsolete)
#running=`ldapsearch -Q -Y EXTERNAL -H "$url" -b "$cpanelobject" -s one "(status=running)" | grep ^dn: | wc -l`
#if [ "$running" -gt 0 ]; then
  #atencion, si uno de los modulos al menos está en running, hay que esperar al siguiente cron!
#  echo "Modules running: $locked, exiting"
#  exit 1
#fi

# Search if any of the modules is locked
locked=`ldapsearch -Q -Y EXTERNAL -H "$url" -b "$cpanelobject" -s one "(status=locked)" | grep ^dn: | wc -l`
echo "Modules locked: $locked"


# If locked trigger cpanel-puppet (local puppet)
if [ "$locked" -gt 0 ]; then

  ## If repo is out of date, pull and exit
  cd /usr/share/cpanel-puppet
  UPSTREAM=${1:-'@{u}'}
  LOCAL=$(git rev-parse @)
  REMOTE=$(git rev-parse "$UPSTREAM")
  BASE=$(git merge-base @ "$UPSTREAM")
  if [ $LOCAL = $REMOTE ]; then
    echo "Up-to-date, continue"
  elif [ $LOCAL = $BASE ]; then
    echo "Need to pull, exit"
    /usr/bin/git pull
    exit 1
  fi

  echo "cpanel-puppet is locked, triggering puppet!"


  # Search puppet modules to enabled
  modules=()
  while IFS= read -r line; do
    modules+=( "$line" )
    echo "$line"
    # Change module status to 'ready'
    setlockstatus "$line" ready
  done < <( ldapsearch -Q -Y EXTERNAL -H "$url" -b "$cpanelobject" -s one "(&(objectclass=*)(status=locked))" | awk -F ": " '$1 == "ou" {print $2}' )

  # Build FACTER params string
  # FACTER_module1=enabled FACTER_module2=enabled
  for i in "${modules[@]}"
  do
    facter="$facter FACTER_${i}=true"
  done
  echo "$facter"

  # Build puppet commando
  puppet="cd /usr/share/cpanel-puppet && export FACTERLIB='./facts' && $facter /usr/local/bin/puppet apply --detailed-exitcode --modulepath ./modules manifests/site.pp > '${logdir}/${date}_stdout.txt' 2> '${logdir}/${date}_stderr.txt'"
  echo "$puppet"
  eval $puppet

  # Tasks if puppet success or fail
  exitcode=$?
  if [ ${exitcode} -eq 0 ] || [ ${exitcode} -eq 2 ]
    then
      echo "Puppet successful - Exit code ${exitcode}"

    else
      echo "Local Puppet error - Exit code ${exitcode}"

      # Send mail to admin with error log, removing color codes from log file
      cat "${logdir}/${date}_stderr.txt" | sed -r "s/\x1B\[([0-9]{1,2}(;[0-9]{1,2})?)?[m|K]//g" | mail -s "Puppet Error in ${hostname}" $logmail

  fi

  # Change module status to 'ready' (obsolete)
  #for i in "${modules[@]}"
  #  do
  #    setlockstatus "${i}" ready
  #  done

else

  echo "puppet is already running or there's nothing to do, i'll check again in next cron run"
fi

