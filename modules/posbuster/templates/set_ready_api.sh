#!/bin/bash

##### Config ###############################

url="ldapi://"
apiobject="ou=api,dc=example,dc=tld"
hostname=$(hostname)

##### Functions ###############################

function updatevmstatus ()
{

# Get userid, token and api url
userid=`ldapsearch -Q -Y EXTERNAL -H "$url" -b "$apiobject" -s base | awk -F ": " '$1 == "uid" {print $2}'`
tokenbase64=`ldapsearch -Q -Y EXTERNAL -H "$url" -b "$apiobject" -s base | awk -F ":: " '$1 == "userPassword" {print $2}'`
host=`ldapsearch -Q -Y EXTERNAL -H "$url" -b "$apiobject" -s base | awk -F ": " '$1 == "host" {print $2}'`
apiurl="${host}vmupdate/${hostname}"
token=`echo "$tokenbase64" | base64 --decode`

# Update status
curl $apiurl -X POST -H "Content-Type: application/json" -H "X-Auth-Token: ${token}" -H "X-User-Id: ${userid}" -d '{"puppetstatus" : "'"$1"'"}'

}


##### Tasks ###############################

updatevmstatus ready
