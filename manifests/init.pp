# Class: puppet
#
# Installs and manages puppet and the puppet agent service.
#
# Parameters:
#
# Actions:
#
# Requires:
#
# Sample Usage:
#
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
  $puppet_package       = $::puppet::params::puppet_package,
  $user                 = $::puppet::params::user,
  $gid                  = $::puppet::params::gid,
  $user_home            = $::puppet::params::user_home,
  $conf_dir             = $::puppet::params::conf_dir,
  $log_dir              = $::puppet::params::log_dir,
  $ssl_dir              = $::puppet::params::ssl_dir,
  $fact_paths           = $::puppet::params::fact_paths,
  $module_paths         = undef,
  $templatedir          = undef,
  $server               = undef,
  $agent                = 'stopped',
  $report               = false,
  $report_server        = undef,
  $report_port          = undef,
  $showdiff             = undef,
  $pluginsync           = false,
  $environment          = $::environment
) inherits puppet::params {

  $puppet_conf_path     = "${conf_dir}/${::puppet::params::conf_file}"
  $auth_conf_path       = "${conf_dir}/${::puppet::params::auth_conf_file}"
  $fileserver_conf_path = "${conf_dir}/${::puppet::params::fileserver_conf_file}"
  $autosign_conf_path   = "${conf_dir}/${::puppet::params::autosign_conf_file}"
  $hiera_conf_path      = "${conf_dir}/${::puppet::params::hiera_conf_file}"
  $hiera_data_dir       = "${conf_dir}/${::puppet::params::hiera_dir}"

  if is_array($fact_paths){
    # Not that it works on Windows yet but...
    case $::osfamily{
      'Windows':{
        $factpath = join($fact_paths, ';')
      }
      default:{
        $factpath = join($fact_paths, ':')
      }
    }
  } else {
    $factpath = $fact_paths
  }

  if is_array($module_paths){
    # Not that it works on Windows yet but...
    case $::osfamily{
      'Windows':{
        $modulepath = join($module_paths, ';')
      }
      default:{
        $modulepath = join($module_paths, ':')
      }
    }
  } else {
    $modulepath = $module_paths
  }

  package{'puppet':
    ensure => $ensure,
    name   => $puppet_package,
  }

  # should match 'installed' or valid version numbers
  case $ensure {
    /^installed$|^(\d+)?(\.(x|\*|\d+))?(\.(x|\*|\d+))?(|-(\S+))$/: {
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

  group{'puppet_group':
    ensure  => $ensure_present,
    name    => $gid,
    require => Package['puppet'],
  }

  user{'puppet_user':
    ensure     => $ensure_present,
    name       => $user,
    gid        => $gid,
    comment    => 'Puppet configuration management daemon',
    shell      => '/bin/false',
    home       => $user_home,
    managehome => false,
    require    => Package['puppet'],
  }

  file{'puppet_conf_dir':
    ensure  => $ensure_dir,
    path    => $conf_dir,
    require => Package['puppet'],
    ignore  => ['.git'],
  }

  file{'puppet_log_dir':
    ensure  => $ensure_dir,
    path    => $log_dir,
    require => Package['puppet'],
  }

  file{'puppet_ssl_dir':
    ensure  => $ensure_dir,
    path    => $ssl_dir,
    require => Package['puppet'],
  }

  file{'puppet_app_dir':
    ensure  => $ensure_dir,
    path    => $::puppet::params::app_dir,
    force   => true,
    require => Package['puppet'],
  }

  file{'puppet_var_dir':
    ensure  => $ensure_dir,
    path    => $::puppet::params::var_dir,
    force   => true,
    require => Package['puppet'],
  }

  file{'puppet_run_dir':
    ensure  => $ensure_dir,
    path    => $::puppet::params::run_dir,
    force   => true,
    require => Package['puppet'],
  }

  # Create the base puppet.conf
  concat {'puppet_conf':
    ensure  => $ensure_present,
    path    => $puppet_conf_path,
    require => File['puppet_conf_dir'],
  }

  concat::fragment{'puppet_conf_base':
    target  => 'puppet_conf',
    content => template('puppet/puppet.conf.main.erb'),
    order   => '00',
  }

  if $agent == 'running' {
    concat::fragment{'puppet_conf_agent':
      target  => 'puppet_conf',
      content => template('puppet/puppet.conf.agent.erb'),
      order   => '20',
    }
  }

  # Configure the puppet agent daemon
  service{'puppet_agent':
    ensure     => $agent,
    name       => 'puppet',
    enable     => true,
    hasrestart => true,
    hasstatus  => true,
    require    => Concat['puppet_conf']
  }

}