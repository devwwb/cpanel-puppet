#!/bin/bash

hostname=$(hostname)
<%- if @facts['customadminmail'] -%>
adminmail=<%= @facts['customadminmail'] %>
<%- else -%>
adminmail="admin@maadix.org"
<%- end -%>

#send report
cat /etc/maadix/bookworm/logs/posbookworm | mail -s "bookworm Upgrade | posbookworm logs de ${hostname}" $adminmail
