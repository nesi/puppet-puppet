# This manifests does the sanity checking in preparation of installing the puppet client

class puppet (

){
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