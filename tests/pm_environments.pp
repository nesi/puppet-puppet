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
class{'::puppet::master':
  ensure                => installed,
  report_handlers       => ['http','puppetdb'],
  reporturl             => 'http://localhost/reports/upload',
  storeconfigs_backend  => 'puppetdb',
  environmentpath       => '$confdir/environments',
  basemodulepaths       => ['$confdir/modules'],
  require               => [
    Class[
      'apache::mod::passenger'
    ]
  ],
}

puppet::auth::header{'dashboard':
  order   => 'D',
  content => 'the D block holds ACL declarations for the Puppet Dashboard'
}

puppet::auth{'pm_dashboard_access_facts':
  order       => 'D100',
  path        => '/facts',
  description => 'allow the puppet dashboard server access to facts',
  auth        => 'yes',
  allows      => ['puppet.local','dashboard'],
  methods     => ['find','search'],
}

file {'/puppet':
  ensure => 'directory',
}

file {'/puppet/private':
  ensure => 'directory',
}

puppet::fileserver{'private':
  path        => '/private/%H',
  description => 'a private file share containing node specific files',
  require     => File['/puppet/private'],
}

puppet::auth{'private_fileserver':
  order       => 'A550',
  description => 'allow authenticated nodes access to the private file share',
  path        => '/puppet/private',
  allows      => '*',
}

file {'/puppet/public':
  ensure => 'directory',
}

puppet::fileserver{'public':
  path        => '/public',
  description => 'a public file share containing node specific files',
  require     => File['/puppet/public'],
}

puppet::auth{'public_fileserver':
  order       => 'A560',
  description => 'allow authenticated nodes access to the public file share',
  path        => '/puppet/public',
  allows      => '*',
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

puppet::autosign{'*.local': }