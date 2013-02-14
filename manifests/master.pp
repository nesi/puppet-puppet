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
	require apache
	require apache::mod::passenger

	# NOTE: If passenger tuning is available it is recommended that the following
	# tuning parameters are passed to apache::mod::passenger
	# Look at this fork: https://github.com/nesi/puppetlabs-apache/tree/passenger_tuning
	# DON'T uncommment this!
	# class {'apache::mod::passenger': 
	# 	passengerhighperformance 	=> 'on',
	# 	passengermaxpoolsize			=> 12,
	# 	passengerpoolidletime			=> 1500,
	# 	# passengermaxrequests			=> 1000,
	# 	passengerstattrottlerate	=> 120,
	# 	rackautodetect						=> 'off',
	# 	railsautodetect 					=> 'off',
	# }

	package{$puppet::params::puppetmaster_package:
	 ensure 	=> $ensure, 
	}

	augeas{'puppetmaster_ssl_config':
		context => "/files${puppet::params::conf_path}",
		changes	=> [
			"set master/ssl_client_header SSL_CLIENT_S_DN",
			"set master/ssl_client_verify_header SSL_CLIENT_VERIFY",
		],
		require	=> Package[$puppet::params::puppetmaster_package],
	}

	# Something should be done here to bring the puppetmaster site configuration
	# under the management of the Puppet apache module, though the default installed
	# with the package should just work
	# It looks like the Apache module does not yet have the sophistication to
	# configure the puppetmaster application

	file{$puppet::params::puppetmaster_docroot:
		ensure => directory,
		require => File[$puppet::params::app_dir],
	}

	apache::vhost{'puppetmaster_dynaguppy':
		port 			=> 8140,
		docroot		=> $puppet::params::puppetmaster_docroot,
		ssl 			=> true,
		priority	=> 50,
	}

}