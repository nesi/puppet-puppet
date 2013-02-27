# This installs the hiera package and makes sure some kind of
# configuration exists
#
# NOTE: This class should not be called directly, instead use:
# include puppet::hiera
# or
# class {'puppet::hiera': }

class puppet::hiera::install(
  $ensure,
  $hiera_config_file,
  $hiera_config_source,
  $hiera_backend_yaml,
  $hiera_backend_json,
  $hiera_datadir,
  $hiera_hierarchy
) {

  # Hiera is installed with the puppet package with Puppet 3.x
  # so must only be installed with 2.x
  if $puppet_version =~ /^2\.*$/ {
    package{$puppet::params::hiera_package:
      require => Package['$puppet::params::puppet_package'],
    }
  }

  augeas{'puppet_config_hiera_config':
    context => "/files${puppet::params::conf_path}",
    changes => ["set master/hiera_config ${hiera_config_file}"],
    require => Package[$puppet::params::puppet_package],
  }

# I'd rather use augeas for this but there is no lense available for the hiera.yaml format
  if $hiera_config_source == false {
    file{$hiera_config_file:
      ensure => file,
      content => template($puppet::params::hiera_config_content),
      require => Package[$puppet::params::puppet_package],
    }
  } else {
    file{$hiera_config_file:
      ensure => file,
      source => $hiera_config_source,
      require => Package[$puppet::params::puppet_package],
    }
  }

  file{"/etc/hiera.yaml":
    ensure  => link,
    target  => $hiera_config_file,
    require => File[$hiera_config_file],
  }

  file{$hiera_datadir:
    ensure  => directory,
    require => $puppet::environments ? {
      false   => Package[$puppet::params::puppet_package],
      default => [Package[$puppet::params::puppet_package],File[$puppet::params::environments_dir]],
    }
  }

}