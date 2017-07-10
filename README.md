# cpanel-puppet
Local puppet manifests for https://github.com/MaadixNet/cpanel-ldap

# How to run

    export FACTERLIB="./facts"
    FACTER_module1=enabled puppet apply --modulepath ./modules manifests/site.pp

# Modules included

    opendkim

# Modules TODO

    add vhosts to apache
    webapp module to install cms with mysql support
    purge certbot renewal files
    rainloop domains

