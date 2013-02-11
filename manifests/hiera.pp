# This manifest does the sanity checking in preparation of installing and 
# configuring hiera http://projects.puppetlabs.com/projects/hiera
# Hiera is installed as part of the Puppet package, hence it is appropriate
# Install and manage it as part of the Puppet installation int this Puppet
# module
#
# This is _not_ required in Puppet 3.x!

class puppet::hiera(
	$ensure								= present,
	$hiera_config_file		= false,
	$hiera_config_source	= false,
	$hiera_backend_yaml		= false,
	$hiera_backend_json		= true,
	$hiera_datadir				= false,
	$hiera_hierarchy			= ['commmon']
	) {

	require puppet
	include puppet::params

	class {'puppet::hiera::install':
		ensure							=> $ensure,
		hiera_config_file		=> $hiera_config_file ? {
			false 	=> $puppet::params::hiera_config_file,
			default	=> $hira_config_file,
		},
		hiera_config_source	=> $hiera_config_source,
		hiera_backend_yaml	=> $hiera_backend_yaml,
		hiera_backend_json	=> $hiera_backend_json,
		hiera_datadir				=> $hiera_datadir ? {
			false		=> $puppet::environments ? {
				false 	=> $puppet::params::hiera_datadir,
				default	=> $puppet::params::hiera_envs_datadir,
			},
			default	=> $hiera_datadir,
		},
		hiera_hierarchy 			=> $hiera_hierarchy,
	}
}