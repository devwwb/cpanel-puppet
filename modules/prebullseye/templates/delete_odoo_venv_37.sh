#!/bin/bash

echo "## Delete odoo venv #####################################################"
#delete odoo venv 3.7
if [ -d /var/www/odoo/venv3 ]; then
  rm -r /var/www/odoo/venv3
fi
