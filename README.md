# R1Soft

WARNING: This module has been renamed from sensson-idera to puppet-r1soft.

This module can install both an R1Soft Server Backup Manager server as an 
R1Soft Server Backup agent.

## Examples

Install the R1Soft server. There are a lot of options available. Please note
that we are rewriting the config each time something changes. It does limit
you in terms of what you can change through the web interface. However, if
you set it up right from the start there is no need to that anyway.

The ssl_keystore value expects you to manage that file yourself. It doesn't
do that for you yet, though you can use puppetlabs/java_ks to manage it for
you.

```
class { 'r1soft': }
```

## Server Backup Manager setup

```
class { 'r1soft::server':
	api_enabled 				=> 'true',		

	http_enabled				=> 'false',
	http_port					=> 80,
	http_max_connections		=> 100,
		
	ssl_enabled					=> 'true',
	ssl_port					=> 443,
	ssl_max_connections			=> 100,
	ssl_keystore				=> '/usr/sbin/r1soft/conf/keystore',
}
```

It's recommended to use puppetlabs/java_ks to manage your keystore. An
example of its use can be found below:

```
package { 'r1soft-java':
	name			=> $::r1soft::java_package,
	ensure 			=> installed,
} ->
java_ks { 'r1soft:truststore':
	ensure       	=> latest,
	certificate  	=> '/usr/sbin/r1soft/data/server.pem',
	private_key		=> '/usr/sbin/r1soft/data/server.key',
	target       	=> '/usr/sbin/r1soft/conf/keystore',
	password     	=> 'password',
	trustcacerts 	=> true,
	require 		=> [ Package['serverbackup-enterprise'], Package['r1soft-java'], ],
	notify			=> Service['cdp-server'],
} ->
java_ks { 'cdp': 
	ensure 			=> absent,
	target       	=> '/usr/sbin/r1soft/conf/keystore',
	password     	=> 'password',
	notify			=> Service['cdp-server'], 
}
```

You need to make sure that /usr/sbin/r1soft/data/server.pem contains a valid
certificate and /usr/sbin/r1soft/data/server.key contains a valid private key.

## Agent setup

```
class { 'r1soft::agent': 
	r1soft_server_ip			=> '192.168.128.1',
	r1soft_server_port			=> '1167',
	r1soft_server_https			=> 'on',
}
```

The init file only contains the repositories for now. You need to be specific
in what you want to install.
