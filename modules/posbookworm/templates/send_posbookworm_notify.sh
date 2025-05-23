#!/bin/bash

hostname=$(hostname)
<%- if @facts['customadminmail'] -%>
adminmail=<%= @facts['customadminmail'] %>
<%- else -%>
adminmail="admin@maadix.org"
<%- end -%>

#send notify
echo "Posbookworm ejecutado ok en ${hostname}

Hay que notificar al user de que la vm ya está actualizada y lista" | mail -s "bookworm Upgrade | Posbookworm OK | Upgrade finalizado en ${hostname}" $adminmail


