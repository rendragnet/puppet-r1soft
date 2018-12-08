class r1soft::agent(
  $package_ensure = 'installed',
  $service_ensure = 'running',
) inherits r1soft {
  # make sure this doesn't get installed on openvz containers, there's no
  # support for that in r1soft
  if $::virtual != 'openvz' {
    case $::operatingsystem {
      redhat, centos: {
        package { 'serverbackup-enterprise-agent':
          ensure  => $package_ensure,
          require => Yumrepo['r1soft'],
        }
      }
      debian, ubuntu: {
        package { 'serverbackup-enterprise-agent':
          ensure  => $package_ensure,
          require => [ Apt::Source['r1soft'], Exec['apt_update'], ]
        }
      }
      default: {
        fail("${::operatingsystem} is not supported.")
      }
    }

    # only do this if its a physical server
    if $facts['os']['family'] == 'RedHat' {
      if $::virtual == 'openvzhn' {
        if $::operatingsystemmajrelease == '5' {
          $kerneldevel = 'ovzkernel-devel'
        }
        else {
          $kerneldevel = 'vzkernel-devel'
        }
      }
      else {
        $kerneldevel = 'kernel-devel'
      }

      package { [ $kerneldevel ]:
        ensure => $package_ensure,
        before => [ Exec['r1soft-get-module'] ],
      }
    }

    exec { 'r1soft-get-module':
      command => '/usr/bin/serverbackup-setup --get-module',
      unless  => "/sbin/lsmod | grep -q 'hcpdriver'",
      require => Package['serverbackup-enterprise-agent'],
      notify  => Service['cdp-agent'],
    }

    # enable the service
    service { 'cdp-agent':
      ensure  => $service_ensure,
      enable  => true,
      require => Package['serverbackup-enterprise-agent'],
    }
  }

  $keys = lookup('r1soft::agent::keys', Hash, 'deep', {})
  create_resources('r1soft::agent::key', $keys)
}
