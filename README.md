# puppet-lumberjack

A puppet module for managing and configuring lumberjack

https://github.com/jordansissel/lumberjack

This module is puppet 3 tested

## Usage

### Set up a parent instance.  This sets up the "framework" config to add individual file/file-group watchers that can be tagged with individual fields.

    lumberjack::instance{
      'core':
        host        => 'logstash.blah.com',
        port        => '5005',
        ssl_ca_file => 'puppet:///modules/conf/etc/ssl/certs/ca.crt',
        provider    => 'daemontools';
    }

### Add watchers that plug in to the intance you set up.
    lumberjack::watcher {
      'syslog':
        part_of => 'core',
        files => ["/var/log/secure", "/var/log/messages", "/var/log/*.log", ];

      'statsd':
        part_of => 'core',
        files => ["/data/log/statsd/statsd.log", ];

      'diamond':
        part_of => 'core',
        files => ["/data/log/diamond/diamond.log", ];
    }

### Removal/decommissioning:

     class { 'lumberjack':
       ensure => 'absent',
     }
