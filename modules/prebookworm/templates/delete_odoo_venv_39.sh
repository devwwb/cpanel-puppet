#!/bin/bash
set -e

echo "## Delete odoo venv #####################################################"
#delete odoo venv
if [ -d /var/www/odoo/venv3 ]; then
  rm -r /var/www/odoo/venv3
fi
