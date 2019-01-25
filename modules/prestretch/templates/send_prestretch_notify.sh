#!/bin/bash

hostname=$(hostname)
adminmail="admin@maadix.org"

#send notify
echo "Prestretch ejecutado ok en ${hostname}

Hay que apagar la vm y cambiar los scripts de inicio del template" | mail -s "Stretch Upgrade | Prestretch OK | Ssolicitud de apagado de ${hostname}" $adminmail


