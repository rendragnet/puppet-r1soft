# r1soft::agent::key
define r1soft::agent::key(
  Optional[Enum['present', 'absent']] $ensure = 'present',
  Optional[Enum['http', 'https']]     $prefix = 'https',
  String[1]                           $server = $title,
) {
  case $ensure {
    'present': {
      exec { "r1soft-get-key-${server}":
        command => "/usr/bin/serverbackup-setup --get-key ${prefix}://${server}",
        unless  => "/usr/bin/serverbackup-setup --list-keys | grep -q '${server}'",
        require => [ Package['serverbackup-enterprise-agent'] ],
      }
    }
    'absent': {
      exec { "r1soft-remove-key-${server}":
        command => "/usr/bin/serverbackup-setup --remove-key ${server}",
        onlyif  => "/usr/bin/serverbackup-setup --list-keys | grep -q '${server}'",
        require => [ Package['serverbackup-enterprise-agent'] ],
      }
    }
    default: {
      fail('Unexpected parameter for ensure')
    }
  }
}
