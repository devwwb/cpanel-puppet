#!/bin/bash

hostname=$(hostname)
<%- if @customadminmail -%>
adminmail=<%= @customadminmail %>
<%- else -%>
adminmail="admin@maadix.org"
<%- end -%>

#send notify
echo "Prebuster ejecutado ok en ${hostname}

Hay que apagar la vm y cambiar los scripts de inicio del template" | mail -s "Buster Upgrade | Prebuster OK en ${hostname}" $adminmail


