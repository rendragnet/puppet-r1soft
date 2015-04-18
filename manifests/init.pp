class idera { 
	case $operatingsystem {
		redhat, centos: {
			yumrepo { 'idera':
				baseurl 	=> 'http://repo.r1soft.com/yum/stable/$basearch/',
				descr 		=> 'Idera Repository Server',
				enabled 	=> 1,
				gpgcheck 	=> 0,
				name 		=> 'idera',
			}

			# Set the right java package, this can be used later on with java_ks
			$java_package = "java-1.6.0-openjdk-devel"
		}
		debian, ubuntu: {
			apt::source { 'idera':
				comment		=> 'Idera Repository Server',
				location	=> 'http://repo.r1soft.com/apt',
				release 	=> 'stable',
				repos		=> 'main',
				include_src	=> false,
				key 		=> 'A40384ED',
				key_source 	=> 'http://repo.r1soft.com/r1soft.asc',
			}

			# Set the right java package, this can be used later on with java_ks
			$java_package = "openjdk-7-jre-headless"
		}
	}
}
