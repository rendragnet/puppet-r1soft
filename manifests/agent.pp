class idera::agent($idera_server_ip = '0', $idera_server_port = '1167', $idera_server_https = 'off') inherits idera {
	package { 'serverbackup-enterprise-agent':
		ensure 	=> installed,
		require => Yumrepo['idera'],
	}
	
	if $idera_server_https == 'off' {
		$urlprefix = "http"
	}
	if $idera_server_https == 'on' {
		$urlprefix = "https"
	}
	
	# only do this if its a physical server
	if $idera_server_ip != 0 {
		if $virtual == 'openvzhn' {
			if $operatingsystem == 'CentOS' and $operatingsystemmajrelease == '5' {
				$kerneldevel = "ovzkernel-devel"			
			}
			else {
				$kerneldevel = "vzkernel-devel"
			}
		}
		else {
			$kerneldevel = "kernel-devel"
		}
	
		package { [ "$kerneldevel" ]:
			ensure 		=> installed,
		} ->
		exec { 'idera-get-module':
			command 	=> "/usr/bin/serverbackup-setup --get-module; /sbin/service cdp-agent restart",
			unless		=> "/sbin/lsmod | grep -q 'hcpdriver'",
			require		=> Package['serverbackup-enterprise-agent'],
		} ->
		exec { 'idera-get-key':
			command		=> "/usr/bin/serverbackup-setup --get-key ${urlprefix}://${idera_server_ip}",
			unless		=> "/usr/bin/serverbackup-setup --list-keys | grep -q '${idera_server_ip}'",
			require		=> Package['serverbackup-enterprise-agent'],
		}
	}
	
	# open the right port
	if defined(Class['csf']) {
		csf::ipv4::input { $idera_server_port: }
	}
}