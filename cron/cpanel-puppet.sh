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
logmail="logs@maadix.org"
#debug
if test -f "/etc/maadix/conf/debug"; then
  debug=true
fi

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


# Search if any of the modules is running
running=`ldapsearch -Q -Y EXTERNAL -H "$url" -b "$cpanelobject" -s one "(status=running)" | grep ^dn: | wc -l`
if [ "$running" -gt 0 ]; then
  #atencion, si uno de los modulos al menos está en running, hay que esperar al siguiente cron!
  echo "Modules running: $running, exiting"
  exit 1
fi

# Search if any of the modules is locked
locked=`ldapsearch -Q -Y EXTERNAL -H "$url" -b "$cpanelobject" -s one "(status=locked)" | grep ^dn: | wc -l`
echo "Modules locked: $locked"


# If locked trigger cpanel-puppet (local puppet)
if [ "$locked" -gt 0 ]; then

  ## If repo is out of date, pull and exit
  cd /usr/share/cpanel-puppet
  git fetch
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


  # Search puppet modules to enabled and set status to running
  # Move reboot module if present to the end of the array
  modules=()
  hasreboot=0
  while IFS= read -r line; do
    if [ "$line" = "reboot" ]; then
      hasreboot=1
    else
      modules+=( "$line" )
    fi
    echo "$line"
    # Change module status to 'running'
    setlockstatus "$line" running
  done < <( ldapsearch -Q -Y EXTERNAL -H "$url" -b "$cpanelobject" -s one "(&(objectclass=*)(status=locked))" | awk -F ": " '$1 == "ou" {print $2}' )
  if [ $hasreboot -eq 1 ]; then
    modules+=( "reboot" )
  fi

  # Build FACTER params string and run puppet for each module
  # FACTER_module1=enabled
  for i in "${modules[@]}"
  do
    facter="FACTER_${i}=true"

    # Build puppet commando
    puppet="cd /usr/share/cpanel-puppet && export FACTERLIB='./facts' && $facter /usr/local/bin/puppet apply --detailed-exitcode --modulepath ./modules manifests/site.pp &> ${logdir}/${date}_${i}_stdout.txt"
    echo "$puppet"
    eval $puppet

    # Tasks if puppet success or fail
    exitcode=$?
    if [ ${exitcode} -eq 0 ] || [ ${exitcode} -eq 2 ]; then
      echo "Puppet module ${1} successful - Exit code ${exitcode}"

      if [ "$debug" = true ]; then
        # Send mail to admin with log, removing color codes from log file
        cat "${logdir}/${date}_${i}_stdout.txt" | sed -r "s/\x1B\[([0-9]{1,2}(;[0-9]{1,2})?)?[m|K]//g" | mail -s "Puppet Local ${i} log in ${hostname}" $logmail
      fi

      # Set module status to ready
      setlockstatus "${i}" ready

    else
      echo "Local Puppet ${i} error - Exit code ${exitcode}"

      # Send mail to admin with log, removing color codes from log file
      cat "${logdir}/${date}_${i}_stdout.txt" | sed -r "s/\x1B\[([0-9]{1,2}(;[0-9]{1,2})?)?[m|K]//g" | mail -s "Puppet Error ${i} in ${hostname}" $logmail

      # If error comes from domains or trash module, set its status to error
      if [[ " ${i} " == 'domains' ]] || [[ " ${i} " == 'trash' ]]; then
        setlockstatus "${i}" error
      else
        setlockstatus "${i}" ready
      fi

    fi

  done

else

  echo "puppet is already running or there's nothing to do, i'll check again in next cron run"
fi

