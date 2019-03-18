node default {

  ## opendkim
  include opendkim

  ## reboot
  include reboot

  ## customfqdn
  include customfqdn

  #certs and conf for each domain
  opendkim::domain{$::maildomains:}
  #certs and conf for fqdn
  opendkim::domain{$::fqdn:}

  ## report
  include report

  ## report
  include clean

  ## stretch
  include prestretch
  include posstretch

}
