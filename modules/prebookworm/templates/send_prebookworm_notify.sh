#!/bin/bash

hostname=$(hostname)
<%- if @facts['customadminmail'] -%>
adminmail=<%= @facts['customadminmail'] %>
echo "Prebookworm ejecutado ok en ${hostname}" | mail -s "bookworm Upgrade | Prebookworm OK en ${hostname}" $adminmail
<%- end -%>

#send notify
adminmail="admin@maadix.org"
echo "Prebookworm ejecutado ok en ${hostname}" | mail -s "bookworm Upgrade | Prebookworm OK en ${hostname}" $adminmail


