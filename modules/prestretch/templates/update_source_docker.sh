#!/bin/bash

#update docker repo for stretch
sed -i 's/jessie/stretch/g' /etc/apt/sources.list.d/docker.list


