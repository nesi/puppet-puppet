# This manifests sets the default parameters for installing puppet
class puppet::params{

  # Common variables
  $puppet_package         = 'puppet'
  $conf_dir               = '/etc/puppet'
  $conf_file              = 'puppet.conf'
  $auth_conf_file         = 'auth.conf'
  $fileserver_conf_file   = 'fileserver.conf'
  $autosign_conf_file     = 'autosign.conf'
  $app_dir                = '/usr/share/puppet'
  $user                   = 'puppet'
  $gid                    = 'puppet'
  $user_home              = '/var/lib/puppet'
  $user_shell             = '/bin/false'
  $log_dir                = '/var/log/puppet'
  $var_dir                = '/var/lib/puppet'
  $ssl_dir                = "${var_dir}/ssl"
  $run_dir                = '/var/run/puppet'
  $fact_paths             = ['$vardir/lib/facter','$vardir/facts']
  $template_dir           = "${conf_dir}/templates"
  $hiera_conf_file        = 'hiera.yaml'
  $hiera_dir              = 'hieradata'
  $hiera_package          = 'hiera'
  $puppetmaster_docroot   = "${app_dir}/rack/puppetmasterd/public"
  $minimum_basemodulepath = ['/opt/puppet/share/puppet/modules']
  $autosign_conf_path     = "${conf_dir}/autosign.conf"


  case $::osfamily {
    Debian:{
      $puppetmaster_package   = 'puppetmaster-passenger'
    }
    RedHat:{
      if $::operatingsystemmajrelease in ['7'] {
        $puppetmaster_package   = 'puppetserver'
      } else {
        fail("The NeSI Puppet Puppet module does not support release ${::operatingsystemmajrelease} of ${::osfamily} family of operating systems")
      }
    }
    default:{
      fail("The NeSI Puppet Puppet module does not support ${::osfamily} family of operating systems")
    }
  }
}