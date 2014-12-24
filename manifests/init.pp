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
		}
		debian, ubuntu: {
			apt::source { 'idera':
				comment		=> 'Idera Repository Server',
				location	=> 'http://repo.r1soft.com/apt',
				release 	=> 'stable',
				repos		=> 'main',
				include_src => false,
			} ->
			apt_key { 'idera':
				ensure 		=> present,
				source 		=> 'http://repo.r1soft.com/r1soft.asc',
				id 			=> 'A40384ED',
			}
		}
	}
}
