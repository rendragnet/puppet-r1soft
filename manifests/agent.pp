class r1soft::agent($r1soft_server_ip = '0', $r1soft_server_port = '1167', $r1soft_server_https = 'off') inherits r1soft {
  # make sure this doesn't get installed on openvz containers, there's no support for that in r1soft
  if $::virtual != 'openvz' {
    case $::operatingsystem {
      redhat, centos: {
        package { 'serverbackup-enterprise-agent':
          ensure  => installed,
          require => Yumrepo['r1soft'],
        }
      }
      debian, ubuntu: {
        package { 'serverbackup-enterprise-agent':
          ensure  => installed,
          require => [ Apt::Source['r1soft'], Exec['apt_update'], ]
        }
      }
      default: {
        fail("${::operatingsystem} is not supported.")
      }
    }

    $urlprefix = $r1soft_server_https ? {
      'on'      => 'https',
      'off'     => 'http',
      'default' => 'http',
    }

    # only do this if its a physical server
    if $r1soft_server_ip != 0 {
      if $::operatingsystem == 'CentOS' {
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
          ensure => installed,
          before => [ Exec['r1soft-get-module'], Exec['r1soft-get-key'] ],
        }
      }

      exec { 'r1soft-get-module':
        command => '/usr/bin/serverbackup-setup --get-module; /sbin/service cdp-agent restart',
        unless  => "/sbin/lsmod | grep -q 'hcpdriver'",
        require => Package['serverbackup-enterprise-agent'],
        notify  => Service['cdp-agent'],
      }
      exec { 'r1soft-get-key':
        command => "/usr/bin/serverbackup-setup --get-key ${urlprefix}://${r1soft_server_ip}",
        unless  => "/usr/bin/serverbackup-setup --list-keys | grep -q '${r1soft_server_ip}'",
        require => [ Package['serverbackup-enterprise-agent'], Exec['r1soft-get-module'] ],
      }
    }

    # enable the service
    service { 'cdp-agent':
      ensure  => running,
      enable  => true,
      require => Package['serverbackup-enterprise-agent'],
    }

    # open the right port
    if defined(Class['csf']) {
      csf::ipv4::input { 'r1soft-server-port':
        port => $r1soft_server_port,
      }
    }
  }
}
