# This manifests does the sanity checking in preparation of installing the puppet client

class puppet (
	$pluginsync 			= false,
	$puppetlabs_repo	= false,
	$storeconfig			= false,
	$user_shell				= false
){

	include puppet::params

	case $operatingsystem {
		Ubuntu:{
			class{'puppet::install':
				pluginsync			=> $pluginsync,
				puppetlabs_repo => $puppetlabs_repo,
				storeconfig			=> $storeconfig,
				user_shell			=> $user_shell,
			}
		}
		default:{
			warning("Puppet module is not configured for $operatingsystem on $fqdn.")
		}
	}
}