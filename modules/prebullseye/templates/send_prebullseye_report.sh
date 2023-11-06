#!/bin/bash

hostname=$(hostname)
<%- if @customadminmail -%>
adminmail=<%= @customadminmail %>
<%- else -%>
adminmail="admin@maadix.org"
<%- end -%>

#send report
cat /etc/maadix/bullseye/logs/prebullseye | mail -s "bullseye Upgrade | prebullseye logs de ${hostname}" $adminmail


