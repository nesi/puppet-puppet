# this should install a puppetmaster that reports to a PuppetDB
include puppet
include puppet::conf
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
include puppetdb

# Set up the puppetmaster
class {'puppet::master':
  storeconfigs_backend  => 'puppetdb',
  report_handlers       => ['store','puppetdb'],
  require               => Class['puppetdb'],
}

class {'puppet::master::config':
  manage_storeconfigs     => false,
  manage_report_processor => false,
  require                 => Class['puppet::master'],
}