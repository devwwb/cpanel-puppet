#!/bin/bash

hostname=$(hostname)
adminmail="admin@maadix.org"

#send notify
echo "Prebuster ejecutado ok en ${hostname}

Hay que apagar la vm y cambiar los scripts de inicio del template" | mail -s "Buster Upgrade | Prebuster OK en ${hostname}" $adminmail


