require 'yaml'
require 'net/http'
require 'json'
require 'socket'
require "base64"

##borg mount params

#to debug, use STDERR and run 'puppet facts --debug | grep -A 20 borg_params' in the agent

Facter.add(:borg_params) do
  setcode do

    #check if borbackup module is enabled
    borgbackup = Facter.value(:borgbackup)
    
    #if borgbackup module is enabled
    if borgbackup
      params = {}

      #api params
      hostname = Socket.gethostname
      tokenbase64 = Facter::Util::Resolution.exec('ldapsearch -Q -Y EXTERNAL -H ldapi:// -b ou=api,dc=example,dc=tld -s base | awk -F ":: " \'$1 == "userPassword" {print $2}\'')
      host = Facter::Util::Resolution.exec('ldapsearch -Q -Y EXTERNAL -H ldapi:// -b ou=api,dc=example,dc=tld -s base | awk -F ": " \'$1 == "host" {print $2}\'')
      apiurl = host + '/vm/' + hostname + '/'
      token = Base64.decode64(tokenbase64)

      #get data from api
      uri = URI(apiurl)
      res = Net::HTTP.start(uri.host, uri.port,
        :use_ssl => uri.scheme == 'https') {|http|
        req = Net::HTTP::Get.new uri
        req['X-HOSTNAME'] = hostname
        req['Content-Type'] = 'application/json'
        req['Authorization'] = 'Token ' + token
        res = http.request(req)
      }
      data = JSON.parse(res.body)

      #borg data
      params['borg_enabled'] = data['backup_enabled']
      params['user'] = data['backup_user']
      params['server'] = data['backup_server']
      params['port'] = data['backup_port']
      params['sudouser']=Facter::Util::Resolution.exec('ldapsearch -H ldapi:// -Y EXTERNAL -LLL -s one -b "ou=sshd,ou=People,dc=example,dc=tld" "(&(objectClass=person)(uid=*)(gidnumber=27))" | grep uid: | sed "s|.*: \(.*\)|\1|"')
      params
    end
  end
end

