# This manifests sets the default parameters for installing puppet


class puppet::params{
	case $operatingsystem {
		Ubuntu:{
			$puppet_package 		= 'puppet'
			$user 							= 'puppet'
			$user_home					= '/var/lib/puppet'
			$group 							= 'puppet'
			$conf_dir 					= '/etc/puppet'
			$conf_file 					= 'puppet.conf'
			$conf_path					= "${conf_dir}/${conf_file}"
			$hiera_package 			= 'heira-puppet'
			$hiera_config_file	= "${conf_dir}/hiera.yaml"
		}
	}
}