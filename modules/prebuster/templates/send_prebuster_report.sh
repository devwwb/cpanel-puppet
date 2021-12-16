#!/bin/bash

hostname=$(hostname)
<%- if @customadminmail -%>
adminmail=<%= @customadminmail %>
<%- else -%>
adminmail="admin@maadix.org"
<%- end -%>

#send report
cat /etc/maadix/buster/logs/prebuster | mail -s "Buster Upgrade | prebuster logs de ${hostname}" $adminmail


