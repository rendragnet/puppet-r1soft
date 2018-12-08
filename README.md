# R1Soft

[![Build Status](https://travis-ci.org/sensson/puppet-r1soft.svg?branch=master)](https://travis-ci.org/sensson/puppet-r1soft) [![Puppet Forge](https://img.shields.io/puppetforge/v/sensson/r1soft.svg?maxAge=2592000?style=plastic)](https://forge.puppet.com/sensson/r1soft)

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
class { 'r1soft::server': manage_properties_templates => false, }
```

The current default is to manage settings by specifying parameters in the
class declaration. This has been deprecated in version 0.1.8 and we recommend
to switch to the new `r1soft::config` defined resource or the latest Hiera
create_resources for `r1soft::web_settings` and `r1soft::server_settings`
instead. For this you need to set `manage_properties_templates` to `false`
as shown in the example above.

```
class { 'r1soft::server':
  api_enabled          => 'true',

  http_enabled         => 'false',
  http_port            => 80,
  http_max_connections => 100,

  ssl_enabled          => 'true',
  ssl_port             => 443,
  ssl_max_connections  => 100,
  ssl_keystore         => '/usr/sbin/r1soft/conf/keystore',
}
```

It's recommended to use puppetlabs/java_ks to manage your keystore. An
example of its use can be found below:

```
package { 'r1soft-java':
  name   => $::r1soft::java_package,
  ensure => installed,
} ->
java_ks { 'cdp:truststore':
  ensure       => latest,
  certificate  => '/usr/sbin/r1soft/data/server.pem',
  private_key  => '/usr/sbin/r1soft/data/server.key',
  target       => '/usr/sbin/r1soft/conf/keystore',
  password     => 'password',
  trustcacerts => true,
  require      => [ Package['serverbackup-enterprise'], Package['r1soft-java'], ],
  notify       => Service['cdp-server'],
}
```

You need to make sure that /usr/sbin/r1soft/data/server.pem contains a valid
certificate and /usr/sbin/r1soft/data/server.key contains a valid private key.

## Agent setup

```
class { 'r1soft::agent': }
```

The init file only contains the repositories for now. You need to be specific
in what you want to install.

## Agent keys

You can set up R1soft keys using both the `r1soft::agent::key` definition or
via Hiera.

Using `r1soft::agent::key`:

```
r1soft::agent::key { '10.11.12.13': }
```

Using Hiera:

```
r1soft::agent::keys:
  10.10.10.11:
    ensure: present
```

## Development

We strongly believe in the power of open source. This module is our way
of saying thanks.

This module is tested against the Ruby versions from Puppet's support
matrix. Please make sure you have a supported version of Ruby installed.

If you want to contribute please:

1. Fork the repository.
2. Run tests. It's always good to know that you can start with a clean slate.
3. Add a test for your change.
4. Make sure it passes.
5. Push to your fork and submit a pull request.

We can only accept pull requests with passing tests.

To install all of its dependencies please run:

```
bundle install --path vendor/bundle
```

### Running unit tests

```
bundle exec rake test
```

### Running acceptance tests

The unit tests only verify if the code runs, not if it does exactly
what we want on a real machine. For this we use Beaker. Beaker will
start a new virtual machine (using Vagrant) and runs a series of
simple tests.
