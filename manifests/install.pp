# This manifest installs the puppet client
#
# This manifest should NOT be called directly, use:
#
# include puppet
# 
# for default install.

class puppet::install(
	$package
) {
	package{$package: ensure => installed}
}