# This manifests does the sanity checking in preparation of installing the puppet client

class puppet (
	$pluginsync 				= false,
	$puppetlabs_repo		= false,
	$storeconfigs				= false,
	$user_shell					= false,
	$hiera_config				= false
){

	include puppet::params

	case $operatingsystem {
		Ubuntu:{
			class{'puppet::install':
				pluginsync				=> $pluginsync,
				puppetlabs_repo 	=> $puppetlabs_repo,
				storeconfigs			=> $storeconfigs,
				user_shell				=> $user_shell,
				hiera_config			=> $hiera_config,
			}
		}
		default:{
			warning("Puppet module is not configured for $operatingsystem on $fqdn.")
		}
	}
}