# This manifests does the sanity checking in preparation of installing the puppet client

class puppet (
	$pluginsync = false
){

	include puppet::params

	if ! $pluginsync in [true,false] {
		err("Puppet does not recognise the value ${pluginsync} for the pluginsync parameter on ${fqdn}")
	}

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