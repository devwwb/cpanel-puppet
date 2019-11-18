require 'yaml'

##list of cpanel users and type

#to debug, use STDERR and run 'puppet facts --debug | grep -A 20 cpanel_users' in the agent

Facter.add(:cpanel_users, :type => :aggregate ) do

  #webmaster
  chunk(:uid) do
    users = {}
    
    #get all sftp users but sudo user
    webmasters=Facter::Util::Resolution.exec('ldapsearch -H ldapi:// -Y EXTERNAL -LLL -s one -b "ou=sshd,ou=People,dc=example,dc=tld" "(&(objectClass=person)(gidnumber=' + Facter.value(:sftpusers_gid) + ')(!(gidnumber=27)))" | grep uid: | sed "s|.*: \(.*\)|\1|"')
    if not webmasters.nil?
      webmasters.each_line do |user|
      users[user.strip] = {:uid => user.strip, :type => 'sftp'}
      end
    end
    #get all ssh users but sudo user
    webmasters=Facter::Util::Resolution.exec('ldapsearch -H ldapi:// -Y EXTERNAL -LLL -s one -b "ou=sshd,ou=People,dc=example,dc=tld" "(&(objectClass=person)(!(gidnumber=27))(!(gidnumber=' + Facter.value(:sftpusers_gid) + ')))" | grep uid: | sed "s|.*: \(.*\)|\1|"')
    if not webmasters.nil?
      webmasters.each_line do |user|
      users[user.strip] = {:uid => user.strip, :type => 'ssh'}
      end
    end

    users
  end

end

