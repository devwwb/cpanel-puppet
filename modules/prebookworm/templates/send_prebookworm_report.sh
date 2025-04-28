#!/bin/bash

hostname=$(hostname)
<%- if @facts['customadminmail'] -%>
adminmail=<%= @facts['customadminmail'] %>
cat /etc/maadix/bookworm/logs/prebookworm | mail -s "bookworm Upgrade | prebookworm logs de ${hostname}" $adminmail
<%- end -%>

#send report
adminmail="admin@maadix.org"
cat /etc/maadix/bookworm/logs/prebookworm | mail -s "bookworm Upgrade | prebookworm logs de ${hostname}" $adminmail
