# This manifests does the sanity checking in preparation of installing the puppet client

class puppet (
	$pluginsync 			= false,
	$puppetlabs_repo	= false,
){

	include puppet::params

	if $web_ui != false{
		require Class['apache']
	}

	case $operatingsystem {
		Ubuntu:{
			class{'puppet::install':
				pluginsync			=> $pluginsync,
				puppetlabs_repo => $puppetlabs_repo,
			}
		}
		default:{
			warning("Puppet module is not configured for $operatingsystem on $fqdn.")
		}
	}
}