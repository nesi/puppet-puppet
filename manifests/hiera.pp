# This manifest does the sanity checking in preparation of installing and
# configuring hiera http://projects.puppetlabs.com/projects/hiera
# Hiera is installed as part of the Puppet package, hence it is appropriate
# Install and manage it as part of the Puppet installation int this Puppet
# module
#
# This is _not_ required in Puppet 3.x!
class puppet::hiera(
  $ensure               = present,
  $hiera_config_file    = false,
  $hiera_config_source  = false,
  $hiera_backend_yaml   = false,
  $hiera_backend_json   = true,
  $hiera_datadir        = false,
  $hiera_hierarchy      = ['commmon']
  ) {

  require puppet
  include puppet::params

  if $hiera_config_file {
    $config_file = $puppet::params::hiera_config_file
  } else {
    $config_file = $hiera_config_file
  }

  if $hiera_datadir {
    if $puppet::environments {
      $datadir = $hiera_datadir
    } else {
      $datadir = $puppet::params::hiera_envs_datadir
    }
  } else {
    $datadir = $puppet::params::hiera_datadir
  }

  class {'puppet::hiera::install':
    ensure              => $ensure,
    hiera_config_file   => $config_file,
    hiera_config_source => $hiera_config_source,
    hiera_backend_yaml  => $hiera_backend_yaml,
    hiera_backend_json  => $hiera_backend_json,
    hiera_datadir       => $datadir,
    hiera_hierarchy     => $hiera_hierarchy,
  }
}