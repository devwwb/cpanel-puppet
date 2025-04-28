#!/bin/bash
set -e

echo "## Delete mailman venv #####################################################"
#delete mailman venv
if [ -d /opt/mailman/venv3 ]; then
  rm -r /opt/mailman/venv3
fi
if [ -f /opt/mailman/requirements_venv3.txt ]; then
  rm /opt/mailman/requirements_venv3.txt
fi
