# cpanel-puppet
Local puppet manifests for https://github.com/MaadixNet/cpanel-ldap

# Latest Version
    release_202401

# How to run

    export FACTERLIB="./facts"
    FACTER_module1=true puppet apply --modulepath ./modules:/etc/puppetlabs/code/environments/production/modules manifests/site.pp

# Requirements

    Module ldapdn: https://github.com/gtmtechltd/puppet_ldapdn.git
    Module posix_acl: https://github.com/voxpupuli/puppet-posix_acl.git

# Modules included

    opendkim
    reboot
    customfqdn
    prestretch
    posstretch
    report
    cleanapt
    cleandocker
    samhainreset
    samhaincheck
    domains
    trash
    prebuster
    posbuster
    mysql
    rkhunter
    tally
    fail2ban
    zeyple
    borgbackup
    borgkey
    luks

# Modules TODO

    add vhosts to apache
    webapp module to install cms with mysql support
    purge certbot renewal files
    rainloop domains

