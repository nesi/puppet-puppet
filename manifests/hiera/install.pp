# This installs the hiera package and makes sure some kind of
# configuration exists
#
# NOTE: This class should not be called directly, instead use:
# include puppet::hiera
# or
# class {'puppet::hiera': }

class puppet::heira::install {
	# Hiera is installed with the puppet package with Puppet 3.x
	# so must only be installed with 2.x
	if $puppet_version ~= /^2\.*$/ {
		package{$puppet::params::hiera_package:
			require	=> Package['$puppet::params::puppet_package'],
		}
	}
}