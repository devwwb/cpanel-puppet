# cpanel-puppet
Local puppet manifests for https://github.com/MaadixNet/cpanel-ldap

# Latest Version
    release_201704

# How to run

    export FACTERLIB="./facts"
    FACTER_module1=true puppet apply --modulepath ./modules manifests/site.pp

# Modules included

    opendkim
    reboot

# Modules TODO

    add vhosts to apache
    webapp module to install cms with mysql support
    purge certbot renewal files
    rainloop domains

