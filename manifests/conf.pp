# The puppet::conf class manages the puppet configuration file
# which is /etc/puppet/puppet.conf by default.
class puppet::conf (
  $environment     = $::environment,
  $pluginsync      = true,
  $storeconfigs    = false,
  $puppetmaster    = 'puppet',
  $report          = true,
  $show_diff       = undef,
  $var_dir         = $puppet::params::var_dir ,
  $ssl_dir         = $puppet::params::ssl_dir,
  $run_dir         = $puppet::params::run_dir,
  $fact_path       = $puppet::params::fact_path,
  $template_dir    = $puppet::params::template_dir
) inherits puppet::params {

  # This class requires resources and variables provided by
  # the puppet class!

  Augeas{
    context => "/files${puppet::puppet_conf_path}",
    require => File['puppet_conf'],
  }

  augeas{'puppet_main_conf':
    changes => [
      "set main/pluginsync ${pluginsync}",
      "set main/storeconfigs ${puppet::conf::storeconfigs}",
      "set main/report ${report}",
      "set main/confdir ${puppet::conf_dir}",
      "set main/vardir ${var_dir}",
      "set main/ssldir ${ssl_dir}",
      "set main/rundir ${run_dir}",
      "set main/factpath ${fact_path}",
      "set main/templatedir ${template_dir}"
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

  # clean up commonly 'misplaced' settings
  augeas{'puppet_clean_conf':
    changes => [
      "rm main/server",
      "rm master/server",
      "rm main/envionment",
      "rm master/environment",
    ],
  }

}