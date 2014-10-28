define puppet::autosign 
{
  validate_re($name,'^(\*|[a-z]+)(\.[a-z]+)*$')
  concat::fragment{"autosign_conf_fragment_${name}":
    target  => 'puppet_autosign_conf',
    order   => $order,
    content => $name,
  }
}