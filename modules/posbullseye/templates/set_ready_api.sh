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
apiurl="${host}/vm/${hostname}/"
token=`echo "$tokenbase64" | base64 --decode`

# Update status
curl -s $apiurl -X PATCH -H "Content-Type: application/json" -H "Authorization: Token ${token}" -H "X-HOSTNAME: ${hostname}" -d '{"status" : "'"$1"'"}'

}


##### Tasks ###############################

updatevmstatus 0
