# This manifest installs the puppet client
#
# This manifest should NOT be called directly, use:
#
# include puppet
# 
# for default install.

class puppet::install(
	$package,
	$pluginsync,
	$puppetlabs_repo
) {
	package{$package: ensure => installed}

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
		context => '/files/etc/puppet/puppet.conf',
		changes	=> [
			"set main/pluginsync ${pluginsync}",
		],
	}
}