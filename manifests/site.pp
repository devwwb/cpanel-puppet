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

  ## cleanapt
  include cleanapt

  ## cleandocker
  include cleandocker

  ## samhainreset
  include samhainreset

  ## samhaincheck
  include samhaincheck

  ## stretch
  include prestretch
  include posstretch

  ## domains
  include domains

  ## trash
  include trash

  ## buster
  include prebuster
  include posbuster

  ## mysql
  include mysql

  ## rkhunter
  include rkhunter

  ## tally
  include tally

  ## fail2ban
  include fail2ban

  ## zeyple
  include zeyple

}
