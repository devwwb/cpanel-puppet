#!/bin/bash

hostname=$(hostname)
<%- if @customadminmail -%>
adminmail=<%= @customadminmail %>
<%- else -%>
adminmail="admin@maadix.org"
<%- end -%>

#send report
cat /etc/maadix/buster/logs/posbuster | mail -s "Buster Upgrade | posbuster logs de ${hostname}" $adminmail


