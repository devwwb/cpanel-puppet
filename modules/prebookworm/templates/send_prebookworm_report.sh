#!/bin/bash

hostname=$(hostname)
<%- if @facts['customadminmail'] -%>
adminmail=<%= @facts['customadminmail'] %>
<%- else -%>
adminmail="admin@maadix.org"
<%- end -%>

#send report
cat /etc/maadix/bookworm/logs/prebookworm | mail -s "bookworm Upgrade | prebookworm logs de ${hostname}" $adminmail
