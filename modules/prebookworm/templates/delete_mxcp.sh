#!/bin/bash
set -e

echo "## Delete mxcp ##################################################"

service mxcp stop
rm -r /usr/share/mxcp/express
rm -r /usr/share/mxcp/mxcp_extra_wsgi.conf
rm -r /usr/share/mxcp/var
rm -r /usr/share/mxcp/venv3
service apache2 restart
