#!/bin/bash

#upgrade jessie
apt-get update
apt-get upgrade -y
apt-get dist-upgrade -y
dpkg --audit
#if there's no packages marked as hold, return true instead exit code 1
dpkg --get-selections | grep hold || true

#TODO, check exit code of dpkg commands
