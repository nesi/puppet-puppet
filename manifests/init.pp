# This manifests does the sanity checking in preparation of installing the puppet client
# Note, the .json Hiera backend is enabled by default as the usual .yaml backend
# can not be manipulated with augeas.

class puppet (
  $pluginsync           = false,
  $puppetlabs_repo      = false,
  $storeconfigs         = false,
  $user_shell           = false,
  $environments         = false,
  $puppetmaster         = false
){

  include puppet::params

  case $operatingsystem {
    Ubuntu:{
      class{'puppet::install':
        pluginsync          => $pluginsync,
        puppetlabs_repo     => $puppetlabs_repo,
        storeconfigs        => $storeconfigs,
        user_shell          => $user_shell,
        environments        => $environments,
        puppetmaster        => $puppetmaster,
      }
    }
    default:{
      warning("Puppet module is not configured for $operatingsystem on $fqdn.")
    }
  }
}