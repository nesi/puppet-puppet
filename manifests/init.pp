# This manifests does the sanity checking in preparation of installing the puppet client

class puppet (
	$pluginsync = false
){

	include puppet::params

	case $operatingsystem {
		Ubuntu:{
			class{'puppet::install':
				package 		=> $puppet::params::puppet_package,
				pluginsync	=> $pluginsync,
			}
		}
		default:{
			warning("Puppet module is not configured for $operatingsystem on $fqdn.")
		}
	}
}