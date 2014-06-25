# This resource defines entries in auth.conf
define puppet::auth (
  $order,
  $path           = $title,
  $description    = undef,
  $is_regex       = false,
  $environments   = undef,
  $methods        = undef,
  $auth           = undef,
  $allows         = undef,
  $denys          = undef,
  $allow_ips      = undef,
  $deny_ips       = undef
) {

  $real_path = $is_regex ? {
    false   => $path,
    default => "~ ${path}",
  }

  if $auth {
    validate_re($auth, ['^yes$','^no$','^on$','^off$','^any$'])
  }

  if is_array($environments) {
    $environment_str = join(unique($environments),', ')
  } else {
    $environment_str = $environments
  }

  if is_array($methods) {
    $method_str = join(unique($methods),', ')
  } else {
    $method_str = $methods
  }

  if is_array($allows) {
    $allow_str = join(unique($allows),', ')
  } else {
    $allow_str = $allows
  }

  if is_array($denys) {
    $deny_str = join(unique($denys),', ')
  } else {
    $deny_str = $denys
  }

  if is_array($allow_ips) {
    $allow_ip_str = join(unique($allow_ips),', ')
  } else {
    $allow_ip_str = $allow_ips
  }

  if is_array($deny_ips) {
    $deny_ip_str = join(unique($deny_ips),', ')
  } else {
    $deny_ip_str = $deny_ips
  }

  # This regex confirms auth is of the form [A-Z]\d{3}
  # but reserves 000 entries for header fragments.
  validate_re($order, ['^[A-Z](?!000)[0-9]{3}$'])

  # Note: Using the order here means that we will get 'duplication' errors
  # if two puppet::auth are defined in the same 'slot'. This is intentional.
  concat::fragment{"puppet_auth_conf_${order}":
    target  => 'puppet_auth_conf',
    order   => $order,
    content => template('puppet/auth.conf.fragment.erb'),
  }

}