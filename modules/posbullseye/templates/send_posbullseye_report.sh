#!/bin/bash

hostname=$(hostname)
<%- if @facts['customadminmail'] -%>
adminmail=<%= @facts['customadminmail'] %>
<%- else -%>
adminmail="admin@maadix.org"
<%- end -%>

#send report
cat /etc/maadix/bullseye/logs/posbullseye | mail -s "bullseye Upgrade | posbullseye logs de ${hostname}" $adminmail


