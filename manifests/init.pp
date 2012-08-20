# This manifests does the sanity checking in preparation of installing the puppet client

class puppet (

){

	include puppet::params

	case $operatingsystem {
		Ubuntu:{
			class{'puppet::install':
				package => $puppet::params::package,
			}
		}
		default:{
			warning("Puppet module is not configured for $operatingsystem on $fqdn.")
		}
	}
}