# This class installs and configures a puppet master running on passenger

class puppet::master (
  $ensure               = 'installed',
  $puppetmaster_package = $puppet::params::puppetmaster_package,
  $puppetmaster_docroot = $puppet::params::puppetmaster_docroot,
  $servername           = $::fqdn,
  $manifest             = undef,
  $fix_manifestdir      = undef,
  $report_handlers      = undef,
  $reporturl            = undef,
  $storeconfigs         = undef,
  $storeconfigs_backend = undef
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

  Augeas{
    context => "/files${puppet::puppet_conf_path}",
    require => File['puppet_conf'],
  }

  augeas{'puppetmaster_ssl_config':
    changes => [
      'set master/ssl_client_header SSL_CLIENT_S_DN',
      'set master/ssl_client_verify_header SSL_CLIENT_VERIFY',
    ],
  }

  # Set up manifest and manifestdir settings
  if $manifest {
    if $fix_manifestdir {
      if $manifest =~ /^.*\.pp$/ {
        $manifest_dir = dirname($manifest)
        $conf_manifest_changes = ["set master/manifest ${manifest}","set master/manifestdir ${manifest_dir}"]
      } else {
        $conf_manifest_changes = ["set master/manifest ${manifest}","set master/manifestdir ${manifest}"]
      }
    } else {
      $conf_manifest_changes = ["set master/manifest ${manifest}",'rm master/manifestdir']
    }
  } else {
    $conf_manifest_changes = ['rm master/manifest','rm master/manifestdir']
  }

  augeas{'puppetmaster_manifest_config':
    changes => $conf_manifest_changes,
  }

  # Set up report handling
  if $report_handlers or $reporturl {
    if is_array($report_handlers) {
      $reports_str = join($report_handlers,',')
    } else {
      $reports_str = $report_handlers
    }
    if $reports_str =~ /http/ {
      if $reporturl {
        $conf_reports_changes = ["set master/reports ${reports_str}","set master/reporturl ${reporturl}"]
      } else {
        $conf_reports_changes = ["set master/reports ${reports_str}",'rm master/reporturl']
        warning('The http report handler has been set, but no URL given to the reporturl parameter!')
      }
    } else {
      if $reporturl {
        if $reports_str {
          $reports_with_http_str = join([$reports_str,'http'],',')
        } else {
          $reports_with_http_str = 'http'
        }
        $conf_reports_changes = ["set master/reports ${reports_with_http_str}","set master/reporturl ${reporturl}"]
      } else {
        $conf_reports_changes = ["set master/reports ${reports_str}",'rm master/reporturl']
      }
    }
  } else {
    $conf_reports_changes = ['rm master/reports','rm master/reporturl']
  }

  augeas{'puppetmaster_reports_config':
    changes => $conf_reports_changes,
  }

  # Set up storeconfigs and backends
  if $storeconfigs or $storeconfigs_backend {
    if $storeconfigs_backend {
      $conf_storeconfigs_changes = ['set master/storeconfigs true',"set master/storeconfigs_backend ${storeconfigs_backend}"]
    } else {
      $conf_storeconfigs_changes = ['set master/storeconfigs true','rm master/storeconfigs_backend']
    }
  } else {
    $conf_storeconfigs_changes = ['rm master/storeconfigs','rm master/storeconfigs_backend']
  }

  augeas{'puppetmaster_storeconfigs_config':
    changes => $conf_storeconfigs_changes,
  }

  # clean up duplicated setting entries
  augeas{'puppet_conf_dedup_master':
    changes => [
      'rm main/ssl_client_header',
      'rm agent/ssl_client_header',
      'rm main/ssl_client_verify_header',
      'rm agent/ssl_client_verify_header',
      'rm main/manifest',
      'rm agent/manifest',
      'rm main/manifestdir',
      'rm agent/manifestdir',
      'rm main/reports',
      'rm agent/reports',
      'rm main/reporturl',
      'rm agent/reporturl',
      'rm agent/storeconfigs',
      'rm main/storeconfigs',
      'rm agent/storeconfigs_backend',
      'rm main/storeconfigs_backend'
    ],
  }

  # The ssl settings have been taken directly from the default vhost
  # configuration distributed with the puppetmaster-passenger package
  apache::vhost{'puppetmaster':
    servername        => $servername,
    docroot           => $puppetmaster_docroot,
    access_log        => true,
    access_log_file   => "puppetmaster_${servername}_access_ssl.log",
    error_log         => true,
    error_log_file    => "puppetmaster_${servername}_error_ssl.log",
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