# r1soft::config
define r1soft::config($ensure = 'present', $value = '', $target = 'server') {
  # Tests
  if $value == '' {
    fail('value can\'t be empty')
  }

  if $::r1soft::server::manage_properties_templates {
    fail('You can\'t use manage_properties together with r1soft::config')
  }

  # Set the configuration file, package and service that we're managing
  case $target {
    'web': {
      $package = 'serverbackup-enterprise'
      $config = '/usr/sbin/r1soft/conf/web.properties'
      $service = 'cdp-server'
    }
    'server': {
      $package = 'serverbackup-enterprise'
      $service = 'cdp-server'
      $config = '/usr/sbin/r1soft/conf/server.properties'
    }
    'api': {
      $package = 'serverbackup-enterprise'
      $service = 'cdp-server'
      $config = '/usr/sbin/r1soft/conf/api.properties'
    }
    default: {
      fail("${target} is not supported")
    }
  }

  # Change the configuration file and reload the service
  file_line { "r1soft-config-set-${target}-${title}":
    ensure  => $ensure,
    path    => $config,
    line    => "${title}=${value}",
    match   => "^${title}=",
    require => Package[$package],
    notify  => Service[$service],
  }
}
