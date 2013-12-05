# Define: lumberjack::instance
#
# This define allows you to setup an instance of lumberjack
#
# === Parameters
#
# [*hosts*]
#   Host names or IP addresses of the Logstash instances to connect to
#   Value type is array
#
# [*port*]
#   Port number of the Logstash instance to connect to
#   Value type is number
#   Default value: undef
#   This variable is optional
#
# [*ssl_ca_file*]
#   File to use for the SSL CA
#   Value type is string
#   This variable is mandatory
#
# [*provider*]
#   Set this to true if you want to run this as a service.
#   Set to false if you only want to manage the ssl_ca_file
#   Value type is boolean
#   Default value: true
#   This variable is optional
#
# === Authors
#
# * Richard Pijnenburg <mailto:richard@ispavailability.com>
# * Modified by Jeff Vier <mailto:jeff@jeffvier.com>
#
define lumberjack::instance(
  $ssl_ca_file,
  $hosts,
  $port           = undef,
  $provider       = "daemontools",
) {

  require lumberjack

  File {
    owner => root,
    group => root,
    mode  => 0644
  }

  if ($provider != false ) {
    lumberjack::service{
      $name:
        ssl_ca_file => $ssl_ca_file,
        hosts       => $hosts,
        port        => $port,
        provider    => $provider;
    }
  }

  if (!defined(File["/etc/lumberjack"])) {
    file {
      "/etc/lumberjack":
        ensure => directory;
    }
  }
  if (!defined(File["/etc/lumberjack/${name}"])) {
    file {
      "/etc/lumberjack/${name}":
        ensure => directory;
    }
  }

  file {
    "/etc/lumberjack/${name}/pieces/header":
      ensure  => $ensure,
      content => template("${module_name}/lumberjack.config.json-headerpiece.erb"),
      notify  => $notify_lumberjack;

    "/etc/lumberjack/${name}/pieces/footer":
      ensure  => $ensure,
      content => template("${module_name}/lumberjack.config.json-footerpiece.erb"),
      notify  => $notify_lumberjack;

    "/etc/lumberjack/${name}/ca.crt":
      ensure  => $ensure,
      source  => $ssl_ca_file,
      notify  => $notify_lumberjack;
  }

}
