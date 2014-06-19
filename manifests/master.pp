# This class installs and configures a puppet master running on passenger

class puppet::master (
  $ensure               = 'installed',
  $puppetmaster_package = $::puppet::params::puppetmaster_package,
  $puppetmaster_docroot = $::puppet::params::puppetmaster_docroot,
  $servername           = $::fqdn,
  $manifest             = undef,
  $fix_manifestdir      = undef,
  $report_handlers      = undef,
  $reporturl            = undef,
  $storeconfigs         = undef,
  $storeconfigs_backend = undef,
  $generate_certs       = true
) inherits puppet::params {

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

  # The SSL files installed by the package need to be regenerated
  exec{'puppet_wipe_pkg_ssl':
    command     => "rm -rf ${::puppet::ssl_dir}",
    path        => ['/bin'],
    refreshonly => true,
    before      => File['puppet_ssl_dir'],
    subscribe   => Package['puppetmaster_pkg'],
  }

  case $::osfamily {
    Debian:{
      $puppet_pkg_site_files = "${::apache::vhost_dir}/puppetmaster ${::apache::vhost_enable_dir}/puppetmaster"
    }
    default:{
      $puppet_pkg_site_files = "${::apache::vhost_dir}/puppetmaster"
    }
  }

  # Deleting these now so they don't trigger a change in the next puppet run
  exec{'puppet_wipe_pkg_site_files':
    command     => "rm ${puppet_pkg_site_files}",
    path        => ['/bin'],
    refreshonly => true,
    subscribe   => Package['puppetmaster_pkg'],
    before      => Apache::Vhost['puppetmaster'],
    notify      => Service['httpd'],
  }


  # Set up report handling
  if $report_handlers {
    if $reporturl {
      if is_array($report_handlers) {
        $reports_str = join(unique(flatten($report_handlers, ['http'])), ',')
      } else {
        $report_str = "${report_handlers},http"
      }
    } else {
      if is_array($report_handlers) {
        $reports_str = join(unique($report_handlers), ',')
      } else {
        $report_str = $report_handlers
      }
    }
  } else {
    $report_str = undef
  }

  if ! $reporturl and $reports_str =~ /http/ {
    warning('The http report handler has been set, but no URL given to the reporturl parameter!')
  }

  concat::fragment{'puppet_conf_master':
    target  => 'puppet_conf',
    content => template('puppet/puppet.conf.master.erb'),
    order   => '03',
  }

  if $generate_certs {
    exec{'puppetmaster_generate_certs':
      command => 'puppet cert list -a',
      creates => "${::puppet::ssl_dir}/certs",
      path    => ['/usr/bin'],
      before  => Service['puppet','httpd'],
      require => [File['puppet_ssl_dir'],Exec['puppet_wipe_pkg_ssl']],
      notify  => Service['httpd'],
    }
    exec{'puppetmaster_generate_master_certs':
      command     => 'timeout 15 puppet master --no-daemonize || echo \'Timed out as expected.\'',
      creates     => "${::puppet::ssl_dir}/certs/${servername}.pem",
      path        => ['/usr/bin','/bin'],
      before      => Service['puppet','httpd'],
      require     => Exec['puppetmaster_generate_certs'],
      notify      => Service['httpd'],
    }
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
    ssl_certs_dir     => $::puppet::ssl_dir,
    ssl_cert          => "${::puppet::ssl_dir}/certs/${servername}.pem",
    ssl_key           => "${::puppet::ssl_dir}/private_keys/${servername}.pem",
    ssl_ca            => "${::puppet::ssl_dir}/certs/ca.pem",
    ssl_chain         => "${::puppet::ssl_dir}/certs/ca.pem",
    rack_base_uris    => ['/'],
    request_headers   =>  [
                            'unset X-Forwarded-For',
                            'set X-SSL-Subject %{SSL_CLIENT_S_DN}e',
                            'set X-Client-DN %{SSL_CLIENT_S_DN}e',
                            'set X-Client-Verify %{SSL_CLIENT_VERIFY}e',
                          ],
    subscribe         => Concat['puppet_conf'],
    require           => Package['puppetmaster_pkg'],
  }

}