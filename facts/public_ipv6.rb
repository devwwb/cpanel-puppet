#get public ipv6 using resolv
require "resolv"
require 'socket'

Facter.add(:public_ipv6) do
  setcode do
    fqdn = Addrinfo.getaddrinfo(Socket.gethostname, nil).first.getnameinfo.first
    begin
      dns = Resolv::DNS.new( :nameserver => ['127.0.0.1'] )
      records = dns.getresources(fqdn, Resolv::DNS::Resource::IN::AAAA)
      public_ipv6 = records[0].address.to_s
    rescue
      dns = Resolv::DNS.new( :nameserver => ['1.1.1.1'] )
      records = dns.getresources(fqdn, Resolv::DNS::Resource::IN::AAAA)
      public_ipv6 = records[0].address.to_s
    end
  end
end

