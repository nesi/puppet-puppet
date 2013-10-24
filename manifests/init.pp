# Class: puppet
#
# This manifests does the sanity checking in preparation of installing
# the puppet package and configure the puppet agent
#
# Parameters:
#
# Actions:
#
# Requires:
#
# Sample Usage:
#
# Note, the .json Hiera backend is enabled by default as the usual .yaml backend
# can not be manipulated with augeas.

# This file is part of the puppet Puppet module.
#
#     The puppet Puppet module is free software: you can redistribute it and/or
#     modify it under the terms of the GNU General Public License as published
#     by the Free Software Foundation, either version 3 of the License, or
#     (at your option) any later version.
#
#     The puppet Puppet module is distributed in the hope that it will be
#     useful, but WITHOUT ANY WARRANTY; without even the implied warranty
#     of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#     GNU General Public License for more details.
#
#     You should have received a copy of the GNU General Public License
#     along with the puppet Puppet module.
#     If not, see <http://www.gnu.org/licenses/>.

# [Remember: No empty lines between comments and class definition]
class puppet (
  $ensure               = 'installed',
  $puppet_package       = $puppet::params::puppet_package,
  $user                 = $puppet::params::user,
  $gid                  = $puppet::params::gid,
  $user_home            = $puppet::params::user_home,
  $conf_dir             = $puppet::params::conf_dir,
  $environments         = undef
) inherits puppet::params {

  $puppet_conf_path = "${conf_dir}/${puppet::params::conf_file}"

  package{'puppet':
    ensure  => $ensure,
    name    => $puppet_package,
  }

  # should match 'installed' or valid version numbers
  case $ensure {
    /^installed$|^(\d+)?(\.(x|\*|\d+))?(\.(x|\*|\d+))?(-(\S+))$/: {
      $ensure_dir     = 'directory'
      $ensure_file    = 'file'
      $ensure_present = 'present'
    }
    default: {
      $ensure_dir     = 'absent'
      $ensure_file    = 'absent'
      $ensure_present = 'absent'
    }
  }

  file{'puppet_user_home':
    ensure  => $ensure_dir,
    path    => $user_home,
    require => Package['puppet'],
  }

  user{'puppet_user':
    ensure      => $ensure_present,
    name        => $user,
    gid         => $gid,
    comment     => 'Puppet configuration management daemon',
    shell       => '/bin/false',
    home        => $user_home,
    managehome  => false,
    require     => Package['puppet'],
  }

  file{'puppet_conf_dir':
    ensure  => $ensure_dir,
    path    => $conf_dir,
    require => Package['puppet'],
    ignore  => ['.git'],
  }

  file{'puppet_conf':
    ensure  => $ensure_file,
    path    => $puppet_conf_path,
    require => File['puppet_conf_dir'],
  }

  # Not convinced that this is the best method for intialising puppet.conf
  $conf_firstline = 'This file is managed by Puppet, modifications may be overwritten.'

  augeas{'puppet_conf_firstline':
    context => "/files${puppet_conf_path}",
    changes => [
      'ins #comment before *[1]',
      "set #comment[1] '${conf_firstline}'",
    ],
    onlyif  => "match #comment[.='${conf_firstline}'] size == 0",
    require => File['puppet_conf'],
  }

  if $environments {
    $environments_ensure = $ensure_dir
  } else {
    $environments_ensure = 'absent'
  }

  file{'puppet_environments_dir':
    ensure  => $environments_ensure,
    path    => "${conf_dir}/environments",
    force   => true,
    require => File['puppet_conf_dir'],
  }


}