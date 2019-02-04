#!/bin/bash

hostname=$(hostname)
adminmail="admin@maadix.org"

#send notify
echo "Posstretch ejecutado ok en ${hostname}

Hay que notificar al user de que la vm ya está actualizada y lista" | mail -s "Stretch Upgrade | Posstretch OK | Upgrade finalizado en ${hostname}" $adminmail


