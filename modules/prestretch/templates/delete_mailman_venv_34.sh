#!/bin/bash

#delete mailman venv 3.4
if [ -d /opt/mailman/venv3 ]; then
  rm -r /opt/mailman/venv3
fi
if [ -f /opt/mailman/requirements_venv3.txt ]; then
  rm /opt/mailman/requirements_venv3.txt
fi
