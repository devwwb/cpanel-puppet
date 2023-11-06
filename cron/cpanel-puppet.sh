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
lifetime=3600
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

function reset_module()
{
  now=$(TZ=GMT date +"%Y-%m-%d %H:%M:%S")
  echo "now $now"
  d1=$(ldapsearch -Q -H ldapi:// -Y EXTERNAL -LLL -s base -b "ou=$1,ou=cpanel,dc=example,dc=tld" modifyTimestamp | grep modifyTimestamp: | sed "s|.*: \(.*\)|\1|")
  d1=${d1::-1}
  date1="${d1:0:4}-${d1:4:2}-${d1:6:2} ${d1:8:2}:${d1:10:2}:${d1:12:2}"
  diff=$(( $(date -d "$now" +"+%s") - $(date -d "$date1" +"+%s") ))
  if [ "$diff" -gt "$lifetime" ]; then
    echo "Reset module $1"
    return 0
  else
    wait=$(( "$lifetime" - "$diff"))
    echo "Resetting module $1 in $wait seconds"
    return 1
  fi
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

# If global puppet is running, exit
status=`ldapsearch -Q -Y EXTERNAL -H "$url" -b "$basedn" "$cpaneldn" | awk -F ": " '$1 == "'"$lockattribute"'" {print $2}'`
echo "Global puppet status: $status"
if [[ "$status" = 'running' ]]; then
  echo "Puppet agent is running, exit"
  exit 1
else
  echo "Puppet agent is not running, continue"
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
  #check if modules needs to be reseted a while after launched
  exclude='luks mysql posbuster posstretch prebuster prestretch report'
  while IFS= read -r liner; do
    if [[ ! " $exclude " =~ .*\ $liner\ .* ]] ; then
      echo "not any of $exclude"
      if reset_module $liner; then
        if [ "$liner" = "reboot" ]; then
          echo "$liner to ready"
          setlockstatus "$liner" ready
        else
          echo "$liner to locked"
          setlockstatus "$liner" locked
        fi
      fi
    fi
  done < <( ldapsearch -Q -Y EXTERNAL -H "$url" -b "$cpanelobject" -s one "(&(objectclass=*)(status=running))" | awk -F ": " '$1 == "ou" {print $2}' )
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
    /usr/bin/git pull --no-rebase
    exit 0
  fi

  echo "cpanel-puppet is locked, triggering puppet!"


  # Search puppet modules to enabled and set status to running
  # Move reboot module if present to the end of the array
  # Move luks module if present to the end of the array and disable reboot
  modules=()
  hasreboot=0
  hasluks=0
  while IFS= read -r line; do
    if [ "$line" = "reboot" ]; then
      hasreboot=1
    elif [ "$line" = "luks" ]; then
      hasluks=1
    else
      modules+=( "$line" )
    fi
    echo "$line"
    # Change module status to 'running'
    setlockstatus "$line" running
  done < <( ldapsearch -Q -Y EXTERNAL -H "$url" -b "$cpanelobject" -s one "(&(objectclass=*)(status=locked))" | awk -F ": " '$1 == "ou" {print $2}' )
  if [ $hasluks -eq 1 ]; then
    modules+=( "luks" )
    setlockstatus reboot ready
  fi
  if [ $hasreboot -eq 1 ]; then
    #add reboot only if luks module is not active
    if [ $hasluks -eq 0 ]; then
      modules+=( "reboot" )
    fi
  fi

  # Build FACTER params string and run puppet for each module
  # FACTER_module1=enabled
  for i in "${modules[@]}"
  do
    facter="FACTER_${i}=true"

    # Build puppet commando
    puppet="cd /usr/share/cpanel-puppet && export FACTERLIB='./facts' && $facter /usr/local/bin/puppet apply --detailed-exitcode --modulepath ./modules:/etc/puppetlabs/code/environments/production/modules manifests/site.pp &> ${logdir}/${date}_${i}_stdout.txt"
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

