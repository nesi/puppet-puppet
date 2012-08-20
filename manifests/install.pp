# This manifest installs the puppet client
#
# This manifest should NOT be called directly, use:
#
# include puppet
# 
# for default install.

class puppet::install(
	$package,
	$pluginsync
) {
	package{$package: ensure => installed}

	augeas{'puppet_main_config':
		context => '/files/etc/puppet.conf',
		change	=> [
			"set main/pluginsync ${pluginsync}"
		]
	}
}