# cpanel-puppet
Local puppet manifests for https://github.com/MaadixNet/cpanel-ldap

# Latest Version
    release_202101

# How to run

    export FACTERLIB="./facts"
    FACTER_module1=true puppet apply --modulepath ./modules:/etc/puppetlabs/code/environments/production/modules manifests/site.pp

# Requirements

    Module ldapdn: https://github.com/gtmtechltd/puppet_ldapdn.git

# Modules included

    opendkim
    reboot
    customfqdn
    prestretch
    posstretch
    report
    clean
    samhainreset
    samhaincheck
    domains
    trash
    prebuster
    posbuster

# Modules TODO

    add vhosts to apache
    webapp module to install cms with mysql support
    purge certbot renewal files
    rainloop domains

