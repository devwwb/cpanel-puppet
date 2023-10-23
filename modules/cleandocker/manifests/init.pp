class cleandocker (
  $enabled = str2bool("$::cleandocker"),
) {

  validate_bool($enabled)

  if $enabled {

    #clean unused images and containers
    #https://github.com/spotify/docker-gc
    if ($::docker_group){
      exec { 'clean docker':
        command   => '/usr/bin/docker run --rm --userns host -v /var/run/docker.sock:/var/run/docker.sock -v /etc:/etc -e GRACE_PERIOD_SECONDS=10 spotify/docker-gc',
        logoutput => true,
      }
      exec { 'clean dangling images':
        command     => 'docker rmi -f $(docker images --quiet --filter=dangling=true)',
        path        => ['/usr/bin', '/usr/sbin', '/bin'],
        onlyif      => 'docker images --quiet --filter=dangling=true | grep none',
      }
      exec { 'prune volumes':
        command     => 'docker volume prune -f',
        path        => ['/usr/bin', '/usr/sbin', '/bin'],
      }
    }

  }

}
