#!/bin/bash

#update default_groups array in classifier.yaml
sed -i 's/apache-php-mod/apache-php-fpm/g' /etc/facter/facts.d/classifier.yaml

