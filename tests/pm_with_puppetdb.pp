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
class { 'puppetdb':
  database        => 'embedded',
  listen_address  => '0.0.0.0',
}

# Set up the puppetmaster
class {'puppet::master':
  storeconfigs_backend  => 'puppetdb',
  report_handlers       => ['store','puppetdb'],
  require               => Class['puppetdb'],
}

class { 'puppetdb::master::routes':
  puppet_confdir  => '/etc/puppet',
  require         => Class['puppet::master'],
}