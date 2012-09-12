# This manifest installs the puppet client
#
# This manifest should NOT be called directly, use:
#
# include puppet
# 
# for default install.

class puppet::install(
	$pluginsync,
	$storeconfig,
	$puppetlabs_repo,
) {
	package{$puppet::params::puppet_package: ensure => installed}

	user{'puppet': ensure => present}

	if $puppetlabs_repo == true {
		require apt
		apt::source { "puppetlabs":
		  location          => "http://apt.puppetlabs.com/ubuntu",
		  release           => $lsbdistcodename,
		  repos             => "main",
		  key               => "4BD6EC30",
		  include_src       => true
		}
	}

	augeas{'puppet_main_config':
		context => $puppet::params::conf_path,
		changes	=> [
			"set main/pluginsync ${pluginsync}",
			"set main/storeconfig ${storeconfig}",
		],
	}
}