#!/bin/bash

hostname=$(hostname)
<%- if @facts['customadminmail'] -%>
adminmail=<%= @facts['customadminmail'] %>
cat /etc/maadix/bookworm/logs/posbookworm | mail -s "bookworm Upgrade | posbookworm logs de ${hostname}" $adminmail
<%- end -%>

#send report
adminmail="admin@maadix.org"
cat /etc/maadix/bookworm/logs/posbookworm | mail -s "bookworm Upgrade | posbookworm logs de ${hostname}" $adminmail
