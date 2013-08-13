# Define: lumberjack::instance
#
# This define allows you to setup an instance of lumberjack
#
# === Parameters
#
# [*host*]
#   Host name or IP address of the Logstash instance to connect to
#   Value type is string
#   Default value: undef
#   This variable is optional
#
# [*port*]
#   Port number of the Logstash instance to connect to
#   Value type is number
#   Default value: undef
#   This variable is optional
#
# [*files*]
#   Array of files you wish to process
#   Value type is array
#   Default value: undef
#   This variable is optional
#
# [*ssl_ca_file*]
#   File to use for the SSL CA
#   Value type is string
#   This variable is mandatory
#
# [*fields*]
#   Extra fields to send
#   Value type is hash
#   Default value: false
#   This variable is optional
#
# [*run_as_service*]
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
define lumberjack::watcher(
  $part_of,
  $files,
  $fields = { type => $name, },
  $ensure = present,
) {

  require lumberjack

  File {
    owner => root,
    group => root,
    mode  => 0644
  }

  if ($provider == present ) {
    validate_array($files)
    $logfiles = join($files,' ')

    if $fields {
      validate_hash($fields)
    }
  }

  if (!defined(File["/etc/lumberjack/${part_of}"])) {
    file {
      "/etc/lumberjack/${part_of}":
        ensure => directory;
    }
  }
  if (!defined(File["/etc/lumberjack/${part_of}/pieces"])) {
    file {
      "/etc/lumberjack/${part_of}/pieces":
        ensure => directory;
    }
  }

  file {
    "/etc/lumberjack/${part_of}/pieces/filepiece-${name}":
      ensure  => $ensure,
      content => template("${module_name}/lumberjack.config.json-filepiece.erb"),
      require => Lumberjack::Instance["${part_of}"],
      notify  => $notify_lumberjack;
  }

}
