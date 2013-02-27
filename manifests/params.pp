# This manifests sets the default parameters for installing puppet


class puppet::params{
  case $operatingsystem {
    Ubuntu:{
      $puppet_package       = 'puppet'
      $user                 = 'puppet'
      $user_home            = '/var/lib/puppet'
      $group                = 'puppet'
      $conf_dir             = '/etc/puppet'
      $app_dir              = '/usr/share/puppet'
      $conf_file            = 'puppet.conf'
      $conf_path            = "${conf_dir}/${conf_file}"
      $environments_dir     = "${conf_dir}/environments"
      $hiera_package        = 'heira-puppet'
      $hiera_config_file    = "${conf_dir}/hiera.yaml"
      $hiera_config_content = "puppet${hiera_config_file}.erb"
      $hiera_datadir        = "${conf_dir}/hieradata"
      $hiera_envs_datadir   = "${conf_dir}/environments/${environment}/hieradata"
      $ruby_augeas_package  = "libaugeas-ruby"
      $puppetmaster_package = "puppetmaster-passenger"
      $puppetmaster_docroot = "${app_dir}/rack/puppetmasterd/public"
    }
  }
}