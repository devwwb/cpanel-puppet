#get public ipv6 using resolv
require "resolv"
require 'socket'
require 'ipaddress'

Facter.add(:public_ipv6) do
  setcode do
    fqdn = Addrinfo.getaddrinfo(Socket.gethostname, nil).first.getnameinfo.first
    begin
      dns = Resolv::DNS.new( :nameserver => ['127.0.0.1'] )
      records = dns.getresources(fqdn, Resolv::DNS::Resource::IN::AAAA)
      begin
        public_ipv6 = IPAddress::IPv6.expand records[0].address.to_s
      rescue
        public_ipv6 = nil
      end
    rescue
      dns = Resolv::DNS.new( :nameserver => ['1.1.1.1'] )
      records = dns.getresources(fqdn, Resolv::DNS::Resource::IN::AAAA)
      begin
        public_ipv6 = IPAddress::IPv6.expand records[0].address.to_s
      rescue
        public_ipv6 = nil
      end
    end
  end
end

