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