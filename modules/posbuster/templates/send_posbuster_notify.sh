#!/bin/bash

hostname=$(hostname)
<%- if @customadminmail -%>
adminmail=<%= @customadminmail %>
<%- else -%>
adminmail="admin@maadix.org"
<%- end -%>

#send notify
echo "Posbuster ejecutado ok en ${hostname}

Hay que notificar al user de que la vm ya está actualizada y lista" | mail -s "Buster Upgrade | Posbuster OK | Upgrade finalizado en ${hostname}" $adminmail


