node default {

  ## opendkim
  include opendkim

  ## opendkim
  include reboot

  #certs and conf for each domain
  opendkim::domain{$::maildomains:}
  #certs and conf for fqdn
  opendkim::domain{$::fqdn:}

}
