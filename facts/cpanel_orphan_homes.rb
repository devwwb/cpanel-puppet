require 'yaml'

##facter with deleted users whose homes must be moved to trash (status=totrash)

#to debug, use STDERR and run 'puppet facts --debug | grep -A 20 cpanel_orphan_homes' in the agent

Facter.add(:cpanel_orphan_homes) do

  setcode do
    #build hash with users that are not in ldap anymore
    orphanhomes = {}
    #get all users deleted from ldap (sftp and ssh users)
    users=Facter::Util::Resolution.exec('ldapsearch -H ldapi:// -Y EXTERNAL -LLL -s one -b "ou=users,ou=trash,dc=example,dc=tld" "(&(objectClass=applicationProcess)(status=totrash))" | grep cn: | sed "s|.*: \(.*\)|\1|"')
    if not users.nil?
      #to prevent id command (below) to retrive cached data (user ids of nonexistent users) flush here passwd cache table of nscd
      cleannscdcache = Facter::Core::Execution.execute('nscd -i passwd')
      users.each_line do |user|
        #confirm user doesn't exist in the system, then add to orphanhomes
        #doc: https://tickets.puppetlabs.com/browse/FACT-1284
        uid = Facter::Util::Resolution.exec('ldapsearch -H ldapi:// -Y EXTERNAL -LLL -s base -b "cn=' + user.strip + ',ou=users,ou=trash,dc=example,dc=tld" "(&(objectClass=applicationProcess)(status=totrash))" | grep type: | sed "s|.*: \(.*\)|\1|"')
        if not Facter::Core::Execution.execute('/usr/bin/id -u ' + uid.strip  + ' > /dev/null 2>&1 && echo true || echo false') == "true"
         userhome = Facter::Util::Resolution.exec('ldapsearch -H ldapi:// -Y EXTERNAL -LLL -s base -b "cn=' + user.strip + ',ou=users,ou=trash,dc=example,dc=tld" "(&(objectClass=applicationProcess)(status=totrash))" | grep otherPath: | sed "s|.*: \(.*\)|\1|"')
         trashname = Facter::Util::Resolution.exec('ldapsearch -H ldapi:// -Y EXTERNAL -LLL -s base -b "cn=' + user.strip + ',ou=users,ou=trash,dc=example,dc=tld" "(&(objectClass=applicationProcess)(status=totrash))" | grep cn: | sed "s|.*: \(.*\)|\1|"')         
         orphanhomes[user.strip] = {:uid => user.strip, :home => userhome.strip, :trashname => trashname.strip}
        end
      end
    end
    orphanhomes
  end

end
