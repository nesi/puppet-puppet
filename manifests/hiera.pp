# This manifest does the sanity checking in preparation of installing and
# configuring hiera http://projects.puppetlabs.com/projects/hiera
# Hiera is installed as part of the Puppet package, hence it is appropriate
class puppet::hiera(
  $ensure               = 'installed',
  $hiera_config_file    = $puppet::params::hiera_config_file,
  $hiera_datadir        = $puppet::params::hiera_datadir,
  $hiera_config_source  = undef,
  $hiera_backend        = 'yaml',
  $hiera_hierarchy      = ['commmon']
  ) inherits puppet::params {

  require puppet

  case $ensure {
    /^installed$|^(\d+)?(\.(x|\*|\d+))?(\.(x|\*|\d+))?(|-(\S+))$/: {
      $ensure_dir     = 'directory'
      $ensure_file    = 'file'
      $ensure_link    = 'link'
      $ensure_present = 'present'
    }
    default: {
      $ensure_dir     = 'absent'
      $ensure_file    = 'absent'
      $ensure_link    = 'absent'
      $ensure_present = 'absent'
    }
  }

  # This package was most likely installed with Puppet, and this
  # just provides a definition to work on. The require here just
  # maintains relationships between puppet::hiera and puppet
  package{'hiera':
    ensure  => $ensure,
    name    => $puppet::params::hiera_package,
    require => Package['puppet'],
  }

  if $ensure_present == 'present' {
    $puppet_conf_hiera_change = "set master/hiera_config ${hiera_config_file}"
  } else {
    $puppet_conf_hiera_change = 'rm master/hiera_config'
  }

  # set the location of the hiera config file in the puppet config
  augeas{'puppet_conf_hiera_config':
    context => "/files${puppet::puppet_conf_path}",
    changes => [$puppet_conf_hiera_change],
    require => File['puppet_conf','hiera_conf'],
  }

  augeas{'puppet_conf_heira_dedup':
    context => "/files${puppet::puppet_conf_path}",
    changes => [
      'rm main/hiera_config',
      'rm agent/hiera_config',
    ],
    require => File['puppet_conf'],
  }

  # This puts up a hiera.yaml template as a config file iff one does
  # not exist.
  # augeas is not suitable for managing YAML files as it doen't yet
  # handle file formats that have meaningful line indentation
  # ...more complex management could be done with Ruby
  if $hiera_config_source {
    file{'hiera_conf':
      ensure  => $ensure_file,
      path    => $hiera_config_file,
      source  => $hiera_config_source,
      replace => false,
      require => Package['hiera'],
    }
  } else {
    file{'hiera_conf':
      ensure  => $ensure_file,
      path    => $hiera_config_file,
      content => template('puppet/hiera.yaml.erb'),
      replace => false,
      require => Package['hiera'],
    }
  }

  file{'etc_hiera_conf':
    ensure  => $ensure_link,
    path    => '/etc/hiera.yaml',
    target  => $hiera_config_file,
    require => File['hiera_conf'],
  }

  # Hiera does not require different data directories for different
  # environments, environments should be handled within the hiera
  # hierachy.
  file{'hiera_datadir':
    ensure  => $ensure_dir,
    path    => $hiera_datadir,
    require => Package['hiera'],
  }

}