# This manifests sets the default parameters for installing puppet
class puppet::params{

  # Common variables
  $puppet_package       = 'puppet'
  $conf_dir             = '/etc/puppet'
  $conf_file            = 'puppet.conf'
  $app_dir              = '/usr/share/puppet'
  $user                 = 'puppet'
  $gid                  = 'puppet'
  $user_home            = '/var/lib/puppet'
  $var_dir              = '/var/lib/puppet'
  $ssl_dir              = "${var_dir}/ssl"
  $run_dir              = '/var/run/puppet'
  $fact_path            = "${var_dir}/lib/facter"
  $template_dir         = "${conf_dir}/templates"
  $hiera_config_file    = "${conf_dir}/hiera.yaml"
  $hiera_datadir        = "${conf_dir}/hieradata"
  $hiera_package        = 'hiera'
  $puppetmaster_package = 'puppetmaster-passenger'
  $puppetmaster_docroot = "${app_dir}/rack/puppetmasterd/public"


  case $::osfamily {
    Debian:{
      $ruby_augeas_package  = 'libaugeas-ruby'
    }
    default:{
      fail("The NeSI Puppet Puppet module does not support ${::osfamily} family of operating systems")
    }
  }
}