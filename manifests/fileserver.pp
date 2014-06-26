# This resource defines entries in fileserver.conf
# As per the recommendations in http://docs.puppetlabs.com/puppet/latest/reference/config_file_fileserver.html
# access is controlled via auth.conf, no allow or deny set by this resource.
define puppet::fileserver (
  $path,
  $description,
  $order = $name,
) {

  # names should only have lower case letters, numbers or underscores, and must
  # start with a lower case letter and not end with an underscore.
  validate_re($name, ['^[a-z][a-z0-9_]*[a-z0-9]$'])

  concat::fragment{"fileserver_conf_fragment_${name}":
    target  => 'puppet_fileserver_conf',
    order   => $order,
    content => template('puppet/fileserver.conf.fragment.erb'),
  }

}