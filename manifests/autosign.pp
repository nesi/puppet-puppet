# This resource inserts entries into autosign.conf
define puppet::autosign
{
  validate_re($name,'^(\*|[a-z]+)(\.[a-z]+)+$')
  concat::fragment{"autosign_conf_fragment_${name}":
    target  => 'puppet_autosign_conf',
    order   => $name,
    content => $name,
  }
}