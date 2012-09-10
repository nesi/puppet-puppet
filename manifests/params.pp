# This manifests sets the default parameters for installing puppet


class puppet::params{
	case $operatingsystem {
		Ubuntu:{
			$puppet_package = 'puppet',
			$user 					= 'puppet',
			$group 					= 'puppet',
			$conf_dir 			= '/etc/puppet',
			$conf_file 			= 'puppet.conf',
			$conf_path			= "${conf_dir}/${conf_file}",
		}
	}
}