#!/bin/bash

#upgrade jessie
apt-get update
apt-get upgrade -y
apt-get dist-upgrade -y

#TODO, check exit code of dpkg commands
