#!/bin/bash

echo "## Delete mxcp ##################################################"

service mxcp stop
rm /usr/share/mxcp/* -R
service apache2 restart
