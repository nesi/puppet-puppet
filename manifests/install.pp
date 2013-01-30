# This manifest installs the puppet client
#
# This manifest should NOT be called directly, use:
#
# include puppet
# 
# for default install.

class puppet::install(
	$pluginsync,
	$storeconfigs,
	$puppetlabs_repo,
	$user_shell,
	$hiera_config_file,
	$hiera_config_source,
	$hiera_backend_yaml,
	$hiera_backend_json,
	$hiera_yaml_datadir,
	$hiera_json_datadir
) {

	if $puppetlabs_repo == true {

		apt::source { 'puppetlabs':
		  location   => 'http://apt.puppetlabs.com',
		  repos      => 'main',
		  key        => '4BD6EC30',
		  key_server => 'pgp.mit.edu',
		}

		package{$puppet::params::puppet_package:
		 ensure => installed,
		 require => Apt::Source['puppetlabs'],
		}
	} else {
		package{$puppet::params::puppet_package: ensure => installed}
	}
	

	user{'puppet':
		ensure	=> present,
		shell 	=> $user_shell,
		require	=> Package[$puppet::params::puppet_package],
	}

	augeas{'puppet_main_config':
		context => $puppet::params::conf_path,
		changes	=> [
			"set main/pluginsync ${pluginsync}",
			"set main/storeconfigs ${storeconfigs}",
		],
		require	=> Package[$puppet::params::puppet_package],
	}

	augeas{'puppet_config_hiera_config':
		context => $puppet::params::conf_path,
		changes	=> ["set master/hiera_config ${hiera_config_file}"],
		require	=> Package[$puppet::params::puppet_package],
	}

# I'd rather use augeas for this but there is no lense available for the hiera.yaml format
	if $hiera_config_source == false {
		file{$hiera_config_file:
			ensure => file,
			content => template($puppet::params::hiera_config_content),
			require	=> Package[$puppet::params::puppet_package],
		}
	} else {
		file{$hiera_config_file:
			ensure => file,
			source => $hiera_config_source,
			require	=> Package[$puppet::params::puppet_package],
		}
	}

}