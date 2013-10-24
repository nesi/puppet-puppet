# The puppet::conf class manages the puppet configuration file
# which is /etc/puppet/puppet.conf by default.
class puppet::conf (
  $environment     = $::environment,
  $pluginsync      = true,
  $puppetmaster    = 'puppet',
  $report          = true,
  $show_diff       = undef,
  $module_path     = undef,
  $var_dir         = $puppet::params::var_dir ,
  $ssl_dir         = $puppet::params::ssl_dir,
  $run_dir         = $puppet::params::run_dir,
  $fact_path       = $puppet::params::fact_path,
  $template_dir    = $puppet::params::template_dir
) inherits puppet::params {

  # This class requires resources and variables provided by
  # the puppet class!
  require puppet

  Augeas{
    context => "/files${puppet::puppet_conf_path}",
    require => File['puppet_conf'],
  }

  # module path should be handled in puppet::master
  if $module_path {
    $module_path_change = "set main/modulepath ${module_path}"
  } else {
    if $puppet::environments {
        $module_path_change = "set main/modulepath \$confdir/environments/${::environment}/modules:\$confdir/modules"
      } else {
        $module_path_change = 'set main/modulepath $confdir/modules'
      }
  }

  augeas{'puppet_main_conf':
    changes => [
      "set main/pluginsync ${pluginsync}",
      "set main/report ${report}",
      "set main/confdir ${puppet::conf_dir}",
      "set main/vardir ${var_dir}",
      "set main/ssldir ${ssl_dir}",
      "set main/rundir ${run_dir}",
      "set main/factpath ${fact_path}",
      "set main/templatedir ${template_dir}",
      $module_path_change,
    ],
  }

  if $show_diff {
    $show_diff_change = "set agent/show_diff ${show_diff}"
  } else {
    $show_diff_change = 'rm agent/show_diff'
  }

  augeas{'puppet_agent_conf':
    changes => [
      "set agent/environment ${puppet::conf::environment}",
      "set agent/server ${puppetmaster}",
      $show_diff_change,
    ],
  }

  # clean up duplicated setting entries
  augeas{'puppet_conf_dedup_agent':
    changes => [
      'rm main/server',
      'rm master/server',
      'rm main/envionment',
      'rm master/environment',
    ],
  }

  augeas{'puppet_conf_dedup_main':
    changes => [
      'rm master/pluginsync',
      'rm master/report',
      'rm master/confdir',
      'rm master/vardir',
      'rm master/ssldir',
      'rm master/rundir',
      'rm master/factpath',
      'rm master/templatedir',
      'rm agent/pluginsync',
      'rm agent/report',
      'rm agent/confdir',
      'rm agent/vardir',
      'rm agent/ssldir',
      'rm agent/rundir',
      'rm agent/factpath',
      'rm agent/templatedir',
    ],
  }

}