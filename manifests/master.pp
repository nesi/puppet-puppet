# This class installs and configures a puppet master running on passenger

class puppet::master (
  $ensure               = 'installed',
  $puppetmaster_package = $puppet::params::puppetmaster_package,
  $puppetmaster_docroot = $puppet::params::puppetmaster_docroot,
  $servername           = $::fqdn,
  $httpd_group          = undef
) inherits puppet::params {

  # Puppet needs to be installed and set up beforehand
  require puppet

  if $puppet::ensure == 'absent' {
    fail('The puppet class ensure parameter must not be "absent"!')
  }

  # Apache and Passenger need to be installed and set up beforehand
  # Use the Puppetlabs Apache module (or a fork):
  # https://forge.puppetlabs.com/puppetlabs/apache
  # https://github.com/puppetlabs/puppetlabs-apache
  require apache::mod::passenger

  # NOTE: Use passenger tuning to configure mod_passenger
  # DON'T uncommment this!
  # class {'apache::mod::passenger':
  #   passenger_high_performance    => 'off',
  #   passenger_max_pool_size       => 12,
  #   passenger_pool_idle_time      => 1500,
  #   # passenger_max_requests        => 1000,
  #   passenger_stat_throttle_rate  => 120,
  #   rack_autodetect               => 'off',
  #   rails_autodetect              => 'off',
  # }

  # can't alias to puppetmaster because there is already a package of that name
  package{'puppetmaster_pkg':
    ensure  => $ensure,
    name    => $puppetmaster_package,
  }

  augeas{'puppetmaster_ssl_config':
    context => "/files${puppet::puppet_conf_path}",
    changes => [
      'set master/ssl_client_header SSL_CLIENT_S_DN',
      'set master/ssl_client_verify_header SSL_CLIENT_VERIFY',
    ],
    require => File['puppet_conf'],
  }

  if $httpd_group {
    $docroot_group = $httpd_group
  } else {
    $docroot_group = $apache::params::group
  }

  file{'puppetmaster_docroot':
    ensure  => directory,
    path    => $puppetmaster_docroot,
    group   => $docroot_group,
    recurse => true,
    ignore  => '.git',
    require =>  [ File['puppet_app_dir'],
                  Package['puppet'],
                ],
  }

  # The ssl settings have been taken directly from the default vhost
  # configuration distributed with the puppetmaster-passenger package
  apache::vhost{'puppetmaster_dynaguppy':
    servername        => $servername,
    docroot           => $puppetmaster_docroot,
    port              => 8140,
    priority          => 50,
    ssl               => true,
    ssl_protocol      => '-ALL +SSLv3 +TLSv1',
    ssl_cipher        => 'ALL:!ADH:RC4+RSA:+HIGH:+MEDIUM:-LOW:-SSLv2:-EXP',
    ssl_verify_client => 'optional',
    ssl_options       => '+StdEnvVars +ExportCertData',
    ssl_verify_depth  => 1,
    ssl_certs_dir     => "${puppet::user_home}/ssl",
    ssl_cert          => "${puppet::user_home}/ssl/certs/${servername}.pem",
    ssl_key           => "${puppet::user_home}/ssl/private_keys/${servername}.pem",
    ssl_ca            => "${puppet::user_home}/ssl/certs/ca.pem",
    ssl_chain         => "${puppet::user_home}/ssl/certs/ca.pem",
    rack_base_uris    => ['/'],
    request_headers   =>  [
                            'unset X-Forwarded-For',
                            'set X-SSL-Subject %{SSL_CLIENT_S_DN}e',
                            'set X-Client-DN %{SSL_CLIENT_S_DN}e',
                            'set X-Client-Verify %{SSL_CLIENT_VERIFY}e',
                          ],
  }

}