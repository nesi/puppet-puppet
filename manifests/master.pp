# This class installs and configures a puppet master running on passenger

class puppet::master (
  $ensure = installed
){

  # Puppet needs to be installed and set up beforehand
  require puppet
  include puppet::params

  # Apache and Passenger need to be installed and set up beforehand
  # Use the Puppetlabs Apache module (or a fork):
  # https://forge.puppetlabs.com/puppetlabs/apache
  # https://github.com/puppetlabs/puppetlabs-apache
  require apache::mod::passenger

  # NOTE: If passenger tuning is available it is recommended that the following
  # tuning parameters are passed to apache::mod::passenger
  # Look at this fork: https://github.com/nesi/puppetlabs-apache/tree/passenger_tuning
  # DON'T uncommment this!
  # class {'apache::mod::passenger':
  #   passengerhighperformance  => 'on',
  #   passengermaxpoolsize      => 12,
  #   passengerpoolidletime     => 1500,
  #   # passengermaxrequests      => 1000,
  #   passengerstatthrottlerate => 120,
  #   rackautodetect            => 'off',
  #   railsautodetect           => 'off',
  # }

  package{$puppet::params::puppetmaster_package:
   ensure   => $ensure,
  }

  augeas{'puppetmaster_ssl_config':
    context => "/files${puppet::params::conf_path}",
    changes => [
      "set master/ssl_client_header SSL_CLIENT_S_DN",
      "set master/ssl_client_verify_header SSL_CLIENT_VERIFY",
    ],
    require => Package[$puppet::params::puppetmaster_package],
  }

  # Something should be done here to bring the puppetmaster site configuration
  # under the management of the Puppet apache module, though the default installed
  # with the package should just work
  # It looks like the Apache module does not yet have the sophistication to
  # configure the puppetmaster application

  file{$puppet::params::puppetmaster_docroot:
    ensure => directory,
    group   => $apache::params::group,
    recurse => true,
    ignore  => '.git',
    require => [File[$puppet::params::app_dir],Package[$puppet::params::puppetmaster_package]],
  }

  # NOTE: This vitual host declaration requiers the apache module to have the
  # ssl patch from https://github.com/nesi/puppetlabs-apache/tree/vhost_ssl
  # merged into it.
  # The ssl settings have been taken directly from the default vhost
  # configuration distributed with the puppetmaster-passenger package
  # some of which are _defaults_ and will not be passed through to the vhost
  # configuration file.
  apache::vhost{'puppetmaster_dynaguppy':
    servername          => $::fqdn,
    docroot             => $puppet::params::puppetmaster_docroot,
    port                => 8140,
    priority            => 50,
    ssl                 => true,
    ssl_protocol        => '-ALL +SSLv3 +TLSv1',
    ssl_cipher_suite    => 'ALL:!ADH:RC4+RSA:+HIGH:+MEDIUM:-LOW:-SSLv2:-EXP',
    ssl_verify_client   => 'optional',
    ssl_options         => '+StdEnvVars +ExportCertData',
    ssl_verify_depth    => 1,
    ssl_certs_dir       => "${puppet::params::user_home}/ssl",
    ssl_cert            => "${puppet::params::user_home}/ssl/certs/${::fqdn}.pem",
    ssl_key             => "${puppet::params::user_home}/ssl/private_keys/${::fqdn}.pem",
    ssl_ca              => "${puppet::params::user_home}/ssl/certs/ca.pem",
    ssl_chain           => "${puppet::params::user_home}/ssl/certs/ca.pem",
    request_header      =>  [
                              'unset X-Forwarded-For',
                              'set X-SSL-Subject %{SSL_CLIENT_S_DN}e',
                              'set X-Client-DN %{SSL_CLIENT_S_DN}e',
                              'set X-Client-Verify %{SSL_CLIENT_VERIFY}e',
                            ],
  }

}