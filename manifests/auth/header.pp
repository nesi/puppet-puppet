# Creates headers in auth.conf
define puppet::auth::header (
  $order,
  $content
) {

  validate_re($order,['^[B-Z]$'])

  concat::fragment{"puppet_auth_conf_header_${order}":
    target  => 'puppet_auth_conf',
    order   => "${order}000",
    content => "\n### ${order}000: ${content}\n",
  }

}