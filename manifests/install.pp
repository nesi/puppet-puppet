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
	$hiera_config
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
	}

	$hiera_config_augeas = $hiera_config ? {
		false		=> "rm master/hiera_config",
		default	=> "set master/hiera_config ${hiera_config}"
	}

	augeas{'puppet_config_hiera_config':
		context => $puppet::params::conf_path,
		changes	=> [$hiera_config_augeas]
	}

}