# todo: potentially remove /usr/sbin/r1soft/data/r1backup during the installation
class r1soft::server(
  Optional[Hash] $web_settings = {},
  Optional[Hash] $server_settings = {},
  Optional[Hash] $api_settings = {},
  $manage_properties_templates = bool2str(true),
  $api_enabled = bool2str(true),
  $page_auto_refresh = 3600,
  $com_port = 5443,
  $data_center_use_ssl = bool2str(false),
  $source_ip = '0.0.0.0',
  $task_history_limit = 30,
  $max_running_restore_tasks = 4,
  $max_running_policy_tasks = 4,
  $max_running_tasks = 4,
  $max_running_verification_tasks = 4,
  $disk_safe_soft_heap_limit = 167772160,
  $hard_quota = 4,
  $soft_quota = 5,
  $close_all_disk_safes_on_start_up = bool2str(false),
  $cdp_stats_update_frequency = 1,
  $agent_network_connection_timeout = 1800,
  $disk_safe_cache_max_idle_time = 180,
  $smtp_host = '',
  $mail_smtp_localhost = '',
  $smtp_port = 25,
  $smtp_username = '',
  $smtp_default_return_address = '',
  $smtp_password = '',

  $http_enabled = bool2str(true),
  $http_port = 80,
  $http_max_connections = 100,

  $ssl_enabled = bool2str(false),
  $ssl_port = 443,
  $ssl_max_connections = 100,
  $ssl_keystore = '',

) inherits r1soft {
  # make sure the package is installed
  case $::operatingsystem {
    'redhat', 'centos': {
      package { 'serverbackup-enterprise':
        ensure  => installed,
        require => Yumrepo['r1soft'],
      }
    }
    'debian', 'ubuntu': {
      package { 'serverbackup-enterprise':
        ensure  => installed,
        require => [ Apt::Source['r1soft'], Exec['apt_update'], ],
      }
    }
    default: {
      fail("${::operatingsystem} is not supported.")
    }
  }

  # set up our configurations
  # Deprecated since 0.1.8, will be removed in 1.2.0
  if $manage_properties_templates {
    notify { 'manage_properties_templates is deprecated and will be removed in 1.2.0. Please use r1soft::config instead.': }

    file { '/usr/sbin/r1soft/conf/server.properties':
      ensure  => present,
      owner   => 'root',
      group   => 'root',
      mode    => '0600',
      content => template('r1soft/server.properties'),
      require => Package['serverbackup-enterprise'],
      notify  => Service['cdp-server'],
    }
    file { '/usr/sbin/r1soft/conf/web.properties':
      ensure  => present,
      owner   => 'root',
      group   => 'root',
      mode    => '0644',
      content => template('r1soft/web.properties'),
      require => Package['serverbackup-enterprise'],
      notify  => Service['cdp-server'],
    }
  } else {
    file { '/usr/sbin/r1soft/conf/server.properties':
      ensure  => present,
      owner   => 'root',
      group   => 'root',
      mode    => '0600',
      require => Package['serverbackup-enterprise'],
      notify  => Service['cdp-server'],
    }
    file { '/usr/sbin/r1soft/conf/web.properties':
      ensure  => present,
      owner   => 'root',
      group   => 'root',
      mode    => '0644',
      require => Package['serverbackup-enterprise'],
      notify  => Service['cdp-server'],
    }
    file { '/usr/sbin/r1soft/conf/api.properties':
      ensure  => present,
      owner   => 'root',
      group   => 'root',
      mode    => '0644',
      require => Package['serverbackup-enterprise'],
      notify  => Service['cdp-server'],
    }
  }

  file { '/usr/sbin/r1soft/data/':
    ensure  => directory,
    owner   => 'root',
    group   => 'root',
    require => Package['serverbackup-enterprise'],
  }
  exec { 'r1soft-set-user':
    path    => '/sbin:/bin:/usr/sbin:/usr/bin',
    command => '/usr/bin/r1soft-setup --user admin --pass admin; touch /usr/sbin/r1soft/data/passwordset',
    creates => '/usr/sbin/r1soft/data/passwordset',
    require => [ Package['serverbackup-enterprise'], File['/usr/sbin/r1soft/data/'], ],
  }
  service { 'cdp-server':
    ensure    => running,
    enable    => true,
    hasstatus => true,
    require   => [ Package['serverbackup-enterprise'], Exec['r1soft-set-user'], ],
  }

  # Set up Hiera
  create_resources(r1soft::config, $web_settings, { 'target' => 'web' })
  create_resources(r1soft::config, $server_settings, { 'target' => 'server' })
  create_resources(r1soft::config, $api_settings, { 'target' => 'api' })

  if defined(Class['csf']) {
    # enable some ports, such as the API port etc.
    csf::ipv4::input { 'r1soft-ssl-port':
      port => $ssl_port,
    }
    csf::ipv4::input { 'r1soft-http-port':
      port => $http_port,
    }
    csf::ipv4::input { '1167': }
    csf::ipv4::input { '9443': }

    csf::ipv4::output { '1167': }
    csf::ipv4::output { '3306': }
  }
}
