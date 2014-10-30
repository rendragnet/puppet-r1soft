class idera($manage_csf = false) { 
	case $operatingsystem {
		redhat, centos: {
			yumrepo { 'idera':
				baseurl => 'http://repo.r1soft.com/yum/stable/$basearch/',
				descr => 'Idera Repository Server',
				enabled => 1,
				gpgcheck => 0,
				name => 'idera',
			}
		}
	}
}
