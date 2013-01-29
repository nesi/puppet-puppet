# This manifest does the sanity checking in preparation of installing and 
# configuring hiera http://projects.puppetlabs.com/projects/hiera
# Hiera is installed as part of the Puppet package, hence it is appropriate
# Install and manage it as part of the Puppet installation int this Puppet
# module
#
# This is _not_ required in Puppet 3.x!

class puppet::hiera {
	include puppet::params

	class {'puppet::hiera::install':

	}
}