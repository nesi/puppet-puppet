# This manifest installs the puppet client
#
# This manifest should NOT be called directly, use:
#
# include puppet
#
# for default install.

class puppet::install(
  $ensure,
  $pluginsync,
  $storeconfigs,
  $user_shell,
  $puppetmaster,
  $environments
) {

  # Other packages
  package{$puppet::params::ruby_augeas_package: ensure => installed}

  user{'puppet':
    ensure      => present,
    name        => $user,
    gid         => $gid,
    shell       => $user_shell,
    home        => $puppet::params::user_home,
    managehome  => false,
    require     => Package[$puppet::params::puppet_package],
  }

  file{$puppet::params::conf_dir:
    ensure  => directory,
    owner   => $puppet::params::user,
    group   => $puppet::params::user,
    recurse => true,
    require => Package[$puppet::params::puppet_package],
    ignore  => ['.git'],
  }

  file{$puppet::params::app_dir:
    ensure  => directory,
    owner   => $puppet::params::user,
    group   => $puppet::params::user,
    recurse => true,
    require => Package[$puppet::params::puppet_package],
    ignore  => '.git',
  }

  augeas{'puppet_main_config':
    context => "/files${puppet::params::conf_path}",
    changes => [
      "set main/pluginsync ${pluginsync}",
      "set main/storeconfigs ${storeconfigs}",
    ],
    require => Package[$puppet::params::puppet_package],
  }

  if $puppetmaster {
    $set_master_changes = ["set main/server ${puppetmaster}",]
  } else {
    $set_master_changes = ['rm main/server',]
  }

  augeas{'puppet_set_master':
    context => "/files${puppet::params::conf_path}",
    changes => $set_master_changes,
    require => Package[$puppet::params::puppet_package],
  }

  if $environments {
    file{$puppet::params::environments_dir:
      ensure  => directory,
      path    => $puppet::params::environments_dir,
      ignore  => '.git',
    }
  }

}

