# r1soft
class r1soft {
  case $::operatingsystem {
    'redhat', 'centos': {
      yumrepo { 'r1soft':
        baseurl       => 'http://repo.r1soft.com/yum/stable/$basearch/',
        descr         => 'R1Soft Server Backup Manager Repository',
        enabled       => 1,
        name          => 'r1soft',
        gpgcheck      => 0,
        repo_gpgcheck => 1,
        gpgkey        => 'http://repo.r1soft.com/r1soft.asc',
      }

      # Set the right java package, this can be used later on with java_ks
      $java_package = 'java-1.6.0-openjdk-devel'
    }
    'debian', 'ubuntu': {
      apt::source { 'r1soft':
        comment  => 'R1Soft Server Backup Manager Repository',
        location => 'http://repo.r1soft.com/apt',
        release  => 'stable',
        repos    => 'main',
        include  => {
          src => false,
        },
        key      => {
          id     => '66BD1D82',
          source => 'http://repo.r1soft.com/r1soft.asc',
        },
      }
      # Set the right java package, this can be used later on with java_ks
      $java_package = 'openjdk-7-jre-headless'
    }
    default: {
      fail("${::operatingsystem} is not supported.")
    }
  }
}
