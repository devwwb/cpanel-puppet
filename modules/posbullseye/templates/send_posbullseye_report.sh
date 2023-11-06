#!/bin/bash

hostname=$(hostname)
<%- if @customadminmail -%>
adminmail=<%= @customadminmail %>
<%- else -%>
adminmail="admin@maadix.org"
<%- end -%>

#send report
cat /etc/maadix/bullseye/logs/posbullseye | mail -s "bullseye Upgrade | posbullseye logs de ${hostname}" $adminmail


