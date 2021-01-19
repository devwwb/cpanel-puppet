#!/bin/bash

#delete stretch sources
if [ -f source_php_stretch.list ]; then
  rm /etc/apt/sources.list.d/source_php_stretch.list
fi
if [ -f /etc/apt/sources.list.d/source_php_sury.list ]; then
  rm /etc/apt/sources.list.d/source_php_sury.list
fi
