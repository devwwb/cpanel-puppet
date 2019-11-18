Facter.add('sftpusers_gid') do
  setcode do
    Facter::Core::Execution.execute('getent group | grep sftpusers | awk -F ":" \'{ print $3 }\'')
  end
end
