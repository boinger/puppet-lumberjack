# Define: lumberjack::service
#
# This define sets up the lumberjack service
#
# === Parameters
#
# [*hosts*]
#   Host names or IP addresses of the Logstash instances to connect to
#   Value type is Array
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
define lumberjack::service(
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
    # Input validation
    validate_array($hosts)

    if ! is_numeric($port) {
      fail("\"${port}\" is not a valid port parameter value")
    }

    if ($provider == "daemontools" ) {

      file { "/etc/init.d/lumberjack-${name}": ensure => absent; }
      service { "lumberjack-${name}": ensure => stopped, enable => false; }

      $user = root
      $loguser = root

      daemontools::setup{
        "lumberjack/${name}":
          user    => $user, ## Needed to read some log files.  Sorry.
          loguser => $loguser,
          run     => template("${module_name}/run.erb"),
          logrun  => template("${module_name}/log/run.erb"),
          notify  => Daemontools::Service["lumberjack-${name}"];
      }

      daemontools::service {
        "lumberjack-${name}":
          source  => "/etc/lumberjack/${name}",
          require => Daemontools::Setup["lumberjack/${name}"];
      }
    }
    elsif ($provider == "init.d" ) {

      # Setup init file if running as a service
      $notify_lumberjack = $lumberjack::restart_on_change ? {
        true  => Service["lumberjack-${name}"],
        false => undef,
      }

      file { "/etc/init.d/lumberjack-${name}":
        ensure  => $ensure,
        mode    => 0755,
        content => template("${module_name}/etc/init.d/lumberjack.erb"),
        notify  => $notify_lumberjack
      }

      #### Service management

      # set params: in operation
      if $lumberjack::ensure == 'present' {

        case $lumberjack::params::status {
          # make sure service is currently running, start it on boot
          'enabled': {
            $service_ensure = 'running'
            $service_enable = true
          }
          # make sure service is currently stopped, do not start it on boot
          'disabled': {
            $service_ensure = 'stopped'
            $service_enable = false
          }
          # make sure service is currently running, do not start it on boot
          'running': {
            $service_ensure = 'running'
            $service_enable = false
          }
          # do not start service on boot, do not care whether currently running or not
          'unmanaged': {
            $service_ensure = undef
            $service_enable = false
          }
          # unknown status
          # note: don't forget to update the parameter check in init.pp if you
          #       add a new or change an existing status.
          default: {
            fail("\"${lumberjack::status}\" is an unknown service status value")
          }
        }

      # set params: removal
      } else {

        # make sure the service is stopped and disabled (the removal itself will be
        # done by package.pp)
        $service_ensure = 'stopped'
        $service_enable = false
      }

      # action
      service { $lumberjack::params::service_name:
        ensure     => $service_ensure,
        enable     => $service_enable,
        hasstatus  => $lumberjack::params::service_hasstatus,
        hasrestart => $lumberjack::params::service_hasrestart,
        pattern    => "lumberjack-${name}",
        require    => File["/etc/lumberjack"];
      }

    } else {
      $notify_lumberjack = undef
    }
  }

}
