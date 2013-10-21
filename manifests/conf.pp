# The puppet::conf class manages the puppet configuration file
# which is /etc/puppet/puppet.conf by default.
class puppet::conf (
  $environment     = $::environment,
  $pluginsync      = true,
  $storeconfig     = false,
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

  augeas{'puppet_main_conf':
    context => "/files${puppet::puppet_conf_path}",
    changes => [
      "set main/pluginsync ${pluginsync}",
      "set main/storeconfigs ${puppet::conf::storeconfigs}",
      "set main/report ${report}",
      "set main/server ${puppetmaster}",
      "set main/confdir ${puppet::conf_dir}",
      "set main/vardir ${var_dir}",
      "set main/ssldir ${ssl_dir}",
      "set main/factpath ${fact_path}",
      "set main/templatedir ${template_dir}"
    ],
    require => File['puppet_conf'],
  }

  if $show_diff {
    $show_diff_change = "set agent/show_diff ${show_diff}"
  } else {
    $show_diff_change = 'rm agent/show_diff'
  }

  augeas{'puppet_agent_conf':
    context => "/files${puppet::puppet_conf_path}",
    changes => [
      "set agent/environment ${puppet::conf::environmet}",
      $show_diff_change,
    ],
    require => File['puppet_conf'],
  }

}