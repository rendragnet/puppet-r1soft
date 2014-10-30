# Idera

This module can install both an Idera server as an Idera agent.

## Prerequisites

This module depends on CSF on both the agent as the server side.

## Examples

Install the Idera server. There are a lot of options available. Please note
that we are rewriting the config each time something changes. It does limit
you in terms of what you can change through the web interface. However, if
you set it up right from the start there is no need to that anyway.

The ssl_keystore value expects you to manage that file yourself. It doesn't
do that for you yet.

```
class { 'idera': manage_csf => true }
```

If you set it to manage CSF you need our CSF module too.

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

Or if you want to use the agent.

```
class { 'idera::agent': 
	idera_server_ip				=> '192.168.128.1',
	idera_server_port			=> '1167',
	idera_server_https			=> 'on',
}
```

The init file only contains a yum repository for now. You need to be specific
in what you want to install.