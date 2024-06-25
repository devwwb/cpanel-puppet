#!/bin/bash

hostname=$(hostname)
<%- if @facts['customadminmail'] -%>
adminmail=<%= @facts['customadminmail'] %>
<%- else -%>
adminmail="admin@maadix.org"
<%- end -%>

#send notify
echo "Posbullseye ejecutado ok en ${hostname}

Hay que notificar al user de que la vm ya está actualizada y lista" | mail -s "bullseye Upgrade | Posbullseye OK | Upgrade finalizado en ${hostname}" $adminmail


