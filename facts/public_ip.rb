#get public ip using resolv
require "resolv"
require 'socket'

Facter.add(:public_ip) do
  setcode do
    fqdn = Addrinfo.getaddrinfo(Socket.gethostname, nil).first.getnameinfo.first
    dns = Resolv::DNS.new( :nameserver => ['127.0.0.1'] )
    public_ip = dns.getaddress( fqdn ).to_s
  end
end

