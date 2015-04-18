# Idera

This module can install both an Idera server as an Idera agent.

## Examples

Install the Idera server. There are a lot of options available. Please note
that we are rewriting the config each time something changes. It does limit
you in terms of what you can change through the web interface. However, if
you set it up right from the start there is no need to that anyway.

The ssl_keystore value expects you to manage that file yourself. It doesn't
do that for you yet.

```
class { 'idera': }
```

## Server setup

It will automatically pick up support for the CSF module if needed.

```
class { 'idera::server':
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
package { 'idera-java':
	name			=> $::idera::java_package,
	ensure 			=> installed,
} ->
java_ks { 'idera:truststore':
	ensure       	=> latest,
	certificate  	=> '/usr/sbin/r1soft/data/server.pem',
	private_key		=> '/usr/sbin/r1soft/data/server.key',
	target       	=> '/usr/sbin/r1soft/conf/keystore',
	password     	=> 'password',
	trustcacerts 	=> true,
	require 		=> [ Package['serverbackup-enterprise'], Package['idera-java'], ],
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
class { 'idera::agent': 
	idera_server_ip				=> '192.168.128.1',
	idera_server_port			=> '1167',
	idera_server_https			=> 'on',
}
```

The init file only contains a yum repository for now. You need to be specific
in what you want to install.
