# this should install a puppetmaster that reports to a PuppetDB
include puppet
include puppet::hiera

# Set up apache
include apache
class {'apache::mod::passenger':
  passenger_high_performance    => 'off',
  passenger_max_pool_size       => 12,
  passenger_pool_idle_time      => 1500,
  # passenger_max_requests        => 1000,
  passenger_stat_throttle_rate  => 120,
  rack_autodetect               => 'off',
  rails_autodetect              => 'off',
}

# Set up the puppetdb
class { 'puppetdb::server':
  database            => 'embedded',
  listen_address      => '0.0.0.0',
  ssl_listen_address  => '0.0.0.0',
}

# Set up the puppetmaster
class {'puppet::master':
  storeconfigs_backend  => 'puppetdb',
  report_handlers       => ['store','puppetdb'],
}

class {'puppetdb::master::config':
  manage_storeconfigs     => false,
  manage_report_processor => false,
  strict_validation       => false,
  puppet_service_name     => 'httpd',
  require                 => Class['puppet::master'],
}

exec{'puppetdb_ssl_setup':
  command => 'puppetdb ssl-setup',
  path    => ['/usr/sbin','/usr/bin','/bin'],
  creates => '/etc/puppetdb/ssl/private.pem',
  require => Class['puppetdb::master::config','puppet::master'],
  notify  => Service['puppetdb','httpd']
}