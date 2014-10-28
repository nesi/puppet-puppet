# This class installs and configures a puppet master running on passenger

class puppet::master (
  $ensure               = 'installed',
  $puppetmaster_package = $::puppet::params::puppetmaster_package,
  $puppetmaster_docroot = $::puppet::params::puppetmaster_docroot,
  $servername           = $::fqdn,
  $manifest             = undef,
  $report_handlers      = undef,
  $reporturl            = undef,
  $storeconfigs         = undef,
  $storeconfigs_backend = undef,
  $environmentpath      = undef,
  $default_manifest     = undef,
  $basemodulepaths      = undef,
  $regenerate_certs     = true,
  $autosign             = undef,
  $autosign_conf_path   = $::puppet::params::autosign_conf_path
) inherits puppet::params {

  # Apache and Passenger need to be installed and set up beforehand
  # Use the Puppetlabs Apache module (or a fork):
  # https://forge.puppetlabs.com/puppetlabs/apache
  # https://github.com/puppetlabs/puppetlabs-apache
  require apache::mod::passenger

  # NOTE: Use passenger tuning to configure mod_passenger
  # DON'T uncommment this!
  # May need to be modified for Apache 2.4
  # class {'apache::mod::passenger':
  #   passenger_high_performance    => 'off',
  #   passenger_max_pool_size       => 12,
  #   passenger_pool_idle_time      => 1500,
  #   # passenger_max_requests        => 1000,
  #   passenger_stat_throttle_rate  => 120,
  #   rack_autodetect               => 'off',
  #   rails_autodetect              => 'off',
  # }

  if $basemodulepaths {
    $basemodulepath_str = join(unique(flatten([$basemodulepaths, $::puppet::params::minimum_basemodulepath])),':')
  }

  # can't alias to puppetmaster because there is already a package of that name
  package{'puppetmaster_pkg':
    ensure => $ensure,
    name   => $puppetmaster_package,
  }

  if $environmentpath =~ /^\$confdir(.*$)/{
    $environment_dir = "${::puppet::conf_dir}$1"
  } else {
    $environment_dir = $environmentpath
  }

  file{'environment_dir':
    ensure  => 'directory',
    path    => $environment_dir,
    require => Package['puppetmaster_pkg'],
  }

  if $regenerate_certs {
    # The SSL files installed by the package need to be regenerated
    exec{'puppet_wipe_pkg_ssl':
      command     => "rm -rf ${::puppet::ssl_dir}",
      path        => ['/bin'],
      refreshonly => true,
      before      => File['puppet_ssl_dir'],
      subscribe   => Package['puppetmaster_pkg'],
    }
    exec{'puppetmaster_generate_certs':
      command => 'puppet cert list -a',
      creates => "${::puppet::ssl_dir}/certs",
      path    => ['/usr/bin'],
      before  => Service['puppet','httpd'],
      require => [File['puppet_ssl_dir'],Exec['puppet_wipe_pkg_ssl']],
      notify  => Service['httpd'],
    }
    exec{'puppetmaster_generate_master_certs':
      command => 'timeout 30 puppet master --no-daemonize || echo \'Timed out is expected.\'',
      creates => "${::puppet::ssl_dir}/certs/${servername}.pem",
      path    => ['/usr/bin','/bin'],
      before  => Service['puppet','httpd'],
      require => Exec['puppetmaster_generate_certs'],
      notify  => Service['httpd'],
    }
  }

  case $::osfamily {
    Debian:{
      $puppet_pkg_site_files = "${::apache::vhost_dir}/puppetmaster* ${::apache::vhost_enable_dir}/puppetmaster*"
    }
    default:{
      $puppet_pkg_site_files = "${::apache::vhost_dir}/puppetmaster*"
    }
  }

  # Deleting the package distributed site files so:
  # - they don't trigger a change in the next puppet run
  # - make Apache 2.4 whine about broken conf files
  exec{'puppet_wipe_pkg_site_files':
    command     => "rm ${puppet_pkg_site_files}",
    path        => ['/bin'],
    refreshonly => true,
    subscribe   => Package['puppetmaster_pkg'],
    before      => Apache::Vhost['puppetmaster'],
    notify      => Service['httpd'],
  }

  # Set up report handling
  if $report_handlers or $reporturl{
    if $reporturl {
      if is_array($report_handlers) {
        $reports_str = join(unique(flatten([$report_handlers, ['http']])), ', ')
      } elsif $report_handlers {
        $reports_str = "${report_handlers}, http"
      } else {
        $reports_str = 'http'
      }
    } else {
      if is_array($report_handlers) {
        $reports_str = join(unique($report_handlers), ', ')
      } else {
        $reports_str = $report_handlers
      }
    }
  } else {
    $reports_str = undef
  }

  if ! $reporturl and $reports_str =~ /http/ {
    warning('The http report handler has been set, but no URL given to the reporturl parameter!')
  }

  concat::fragment{'puppet_conf_environments':
    target  => 'puppet_conf',
    content => template('puppet/puppet.conf.environments.erb'),
    order   => '10',
  }

  concat::fragment{'puppet_conf_master':
    target  => 'puppet_conf',
    content => template('puppet/puppet.conf.master.erb'),
    order   => '30',
  }

  concat{'puppet_auth_conf':
    path    => $::puppet::auth_conf_path,
    notify  => Service['httpd'],
    require => Package['puppetmaster_pkg'],
  }

  concat::fragment{'auth_conf_boilerplate':
    target  => 'puppet_auth_conf',
    order   => 'A000',
    content => template('puppet/auth.conf.boilerplate.erb'),
  }

  concat{'puppet_autosign_conf':
    path    => $autosign_conf_path,
    warn    => '# This file was generated by Puppet, changes may be overwritten.',
    force   => true,
    notify  => Service['httpd'],
    require => Package['puppetmaster_pkg'],
  }

  puppet::auth{'pm_retrieve_catalog':
    path        => '^/catalog/([^/]+)$',
    description => 'allow nodes to retrieve their own catalog',
    is_regex    => true,
    methods     => 'find',
    allows      => '$1',
    order       => 'A100',
  }

  puppet::auth{'pm_retrieve_node_definitions':
    path        => '^/node/([^/]+)$',
    description => 'allow nodes to retrieve their own node definition',
    is_regex    => true,
    methods     => 'find',
    allows      => '$1',
    order       => 'A200',
  }

  puppet::auth{'pm_allow_ca_services':
    path        => '/certificate_revocation_list/ca',
    description => 'allow all nodes to access the certificates services',
    methods     => 'find',
    allows      => '*',
    order       => 'A300',
  }

  puppet::auth{'pm_allow_store_reports':
    path        => '^/report/([^/]+)$',
    description => 'allow all nodes to store their own reports',
    is_regex    => true,
    methods     => 'save',
    allows      => '$1',
    order       => 'A400',
  }

  puppet::auth{'pm_allow_file_access':
    path        => '/file',
    description => 'allow all nodes to access all file services; this is necessary for pluginsync, file serving from modules, and file serving from custom mount points.',
    allows      => '*',
    order       => 'A500',
  }

  puppet::auth::header{'unauthenticated':
    order   => 'M',
    content => "Blocks M to P contain unauthenticated ACLs, for clients without valid\n### certificates; authenticated clients can also access these paths.",
  }

  puppet::auth{'pm_allow_ca_cert_access':
    path        => '/certificate/ca',
    description => 'allow access to the CA certificate; unauthenticated nodes need this in order to validate the puppet master\'s certificate',
    auth        => 'any',
    methods     => 'find',
    allows      => '*',
    order       => 'M100',
  }

  puppet::auth{'pm_allow_ca_cert_retrieval':
    path        => '/certificate/',
    description => 'allow nodes to retrieve the certificate they requested earlier',
    auth        => 'any',
    methods     => 'find',
    allows      => '*',
    order       => 'M200',
  }

  puppet::auth{'pm_allow_ca_cert_request':
    path        => '/certificate_request',
    description => 'allow nodes to request a new certificate',
    auth        => 'any',
    methods     => ['find','save'],
    allows      => '*',
    order       => 'M300',
  }

  puppet::auth::header{'unknown':
    order   => 'Q',
    content => 'policies in the Q block are not well described or unknown',
  }

  puppet::auth{'pm_v2_environments':
    path        => '/v2.0/environments',
    description => 'this entry exists in the default auth.conf without description',
    methods     => 'find',
    allows      => '*',
    order       => 'Q100',
  }

  puppet::auth::header{'defaults':
    order   => 'X',
    content => 'policies after the X block are defaults',
  }

  puppet::auth{'pm_default_policy':
    path        => '/',
    description => 'deny everything else; this ACL is not strictly necessary, but illustrates the default policy.',
    auth        => 'any',
    order       => 'Z100',
  }

  concat{'puppet_fileserver_conf':
    path    => $::puppet::fileserver_conf_path,
    notify  => Service['httpd'],
    require => Package['puppetmaster_pkg'],
  }

  concat::fragment{'fileserver_conf_boilerplate':
    target  => 'puppet_fileserver_conf',
    order   => '0',
    content => template('puppet/fileserver.conf.boilerplate.erb'),
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