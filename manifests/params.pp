# This manifests sets the default parameters for installing puppet
class puppet::params{

  # Common variables
  $puppet_package       = 'puppet'
  $conf_dir             = '/etc/puppet'
  $conf_file            = 'puppet.conf'
  $user                 = 'puppet'
  $gid                  = 'puppet'
  $user_home            = '/var/lib/puppet'
  $var_dir              = '/var/lib/puppet'
  $ssl_dir              = "${var_dir}/ssl"
  $run_dir              = '/var/run/puppet'
  $fact_path            = "${var_dir}/lib/facter"
  $template_dir         = '$confdir/templates'
  $hiera_config_file    = '$confdir/hiera.yaml'
  $hiera_datadir        = "${conf_dir}/hieradata"
  $hiera_package        = 'heira'


  case $::osfamily {
    Debian:{
      $app_dir              = '/usr/share/puppet'
      
      
      $hiera_config_content = "puppet${hiera_config_file}.erb"
      
      $hiera_envs_datadir   = "${conf_dir}/environments/${environment}/hieradata"
      $ruby_augeas_package  = 'libaugeas-ruby'
      $puppetmaster_package = 'puppetmaster-passenger'
      $puppetmaster_docroot = "${app_dir}/rack/puppetmasterd/public"
    }
    default:{
      fail("The NeSI Puppet Puppet module does not support ${::osfamily} family of operating systems")
    }
  }
}