# This manifest does the sanity checking in preparation of installing and
# configuring hiera http://projects.puppetlabs.com/projects/hiera
# Hiera is installed as part of the Puppet package, hence it is appropriate
class puppet::hiera(
  $ensure               = 'installed',
  $hiera_conf_path      = $::puppet::hiera_conf_path,
  $hiera_data_dir       = $::puppet::hiera_data_dir,
  $hiera_config_manage  = false,
  $hiera_config_source  = undef,
  $hiera_config_content = undef,
  $hiera_backend        = 'yaml',
  $hiera_hierarchy      = ['commmon'],
  $user                 = $::puppet::user,
  $group                = $::puppet::gid
  ) inherits puppet::params {

  # This package was most likely installed with Puppet, and this
  # just provides a definition to work on. The require here just
  # maintains relationships between puppet::hiera and puppet
  package{'hiera':
    ensure  => $ensure,
    name    => $puppet::params::hiera_package,
    require => Package['puppet'],
  }

  case $ensure {
    /^installed$|^(\d+)?(\.(x|\*|\d+))?(\.(x|\*|\d+))?(|-(\S+))$/: {
      $ensure_dir     = 'directory'
      $ensure_file    = 'file'
      $ensure_link    = 'link'
      $ensure_present = 'present'
      concat::fragment{'puppet_conf_hiera':
        target  => 'puppet_conf',
        content => template('puppet/puppet.conf.hiera.erb'),
        order   => '02',
        require => Package['hiera'],
      }
    }
    default: {
      $ensure_dir     = 'absent'
      $ensure_file    = 'absent'
      $ensure_link    = 'absent'
      $ensure_present = 'absent'
    }
  }

  # This puts up a hiera.yaml template as a config file iff one does
  # not exist. Managment of YAML files with puppet not yet implemented.
  # ...more complex management could be done with Ruby
  if $hiera_config_source {
    file{'hiera_conf':
      ensure  => $ensure_file,
      path    => $hiera_conf_path,
      source  => $hiera_config_source,
      owner   => $user,
      group   => $group,
      replace => $hiera_config_manage,
      require => Package['hiera'],
    }
  } else {
    if $hiera_config_content {
      $real_config_content = $hiera_config_content
    } else {
      $real_config_content = template('puppet/hiera.yaml.erb')
    }
    file{'hiera_conf':
      ensure  => $ensure_file,
      path    => $hiera_conf_path,
      content => $real_config_content,
      owner   => $user,
      group   => $group,
      replace => $hiera_config_manage,
      require => Package['hiera'],
    }
  }

  file{'etc_hiera_conf':
    ensure  => $ensure_link,
    path    => '/etc/hiera.yaml',
    target  => $hiera_conf_path,
    require => File['hiera_conf'],
  }

  # Hiera does not require different data directories for different
  # environments, environments should be handled within the hiera
  # hierachy. This might change when directory environments are
  # implemented.
  file{'hiera_data_dir':
    ensure  => $ensure_dir,
    path    => $hiera_data_dir,
    owner   => $user,
    group   => $group,
    recurse => true,
    require => Package['hiera'],
  }

}
