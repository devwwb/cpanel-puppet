#!/bin/bash

hostname=$(hostname)
<%- if @facts['customadminmail'] -%>
adminmail=<%= @facts['customadminmail'] %>
<%- else -%>
adminmail="admin@maadix.org"
<%- end -%>

#send notify
echo "Prebullseye ejecutado ok en ${hostname}" | mail -s "bullseye Upgrade | Prebullseye OK en ${hostname}" $adminmail


