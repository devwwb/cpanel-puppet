#!/bin/bash

hostname=$(hostname)
<%- if @facts['customadminmail'] -%>
adminmail=<%= @facts['customadminmail'] %>
<%- else -%>
adminmail="admin@maadix.org"
<%- end -%>

#send notify
echo "Prebookworm ejecutado ok en ${hostname}" | mail -s "bookworm Upgrade | Prebookworm OK en ${hostname}" $adminmail


