# NeSI Puppet Puppet Module

[![Build Status](https://travis-ci.org/nesi/puppet-puppet.png?branch=refactor)](https://travis-ci.org/nesi/puppet-puppet)

NeSI Puppet Puppet Module is a Puppet module for installing, configuring and managing puppet, puppetmaster, and hiera.

# Introduction

While working on the [dynaguppy](https://github.com/Aethylred/dynaguppy) project a module was required to install and configure puppet, puppetmaster and hiera. As the puppet agent and puppetmaster share configuration files (`/etc/puppet/puppet.conf` in particular), and puppet modules should not attempt to manage files *between* modules, a single puppet and puppetmaster module would be required. Hiera is now installed with Puppet as a dependency, it is appropriate that hiera is configured with this module.

...thus we get puppet recursively puppetising puppet, which can only end in wondrous singularity, or fiery loops of oblivion.

# Usage

## Default Usage

The following puppet snippet will install puppet and enforce the default puppet configuration:  
```puppet
include puppet
```

# Classes

## `puppet`

The `puppet` class installs puppet from packages available to whichever repositories have been [previously configured](#Alternative Repositories). The `puppet` class can be called without parameters to install with defaults, or as a parametric class.

### Parameters

* **ensure**: The ensure parameter specifies the installation state of the puppet configuration. If it is `installed` or a valid version number, Puppet will be installed. If it is `absent` then Puppet will be removed, including any configuration files and directories that were set up. The default value is `installed`.
* **puppet_package**: Specifies the name of the package used to install Puppet. The default value is `puppet`.
* **user**: Specifies the puppet user account. The default value is `puppet`.
* **gid**: The primary group identity of the puppet user. The default value is `puppet`.
* **user_home**: Sets the home directory for the puppet user. The default value is `/var/lib/puppet`.
* **conf_dir**: Sets the directory where the puppet configuration file is stored. The default is `/etc/puppet`.
* **var_dir**: This sets the puppet working directory that contains cached data, configurations and reports. The default is `/var/lib/puppet`.
* **ssl_dir**: This sets the directory where puppet stores SSL state, including certificates and keys. The default is `/var/lib/puppet/ssl`.
* **run_dir**: This sets the `rundir` setting in the `agent` block of the puppet conf. The default setting is `/var/run/puppet`.
* **fact_paths**: This sets a directory or list of directories where facter facts are stored. The default is `$vardir/lib/facter:$vardir/facts` which should resolve to `/var/lib/puppet/lib/facter:/var/lib/puppet/facts`.
* **module_paths**: This sets a directory or list of directories that Puppet will use for the module path. The default is not set. For Puppet version 3.5.0 or later the special variable `$basemodulepath` can be used to include all the default module paths.
* **template_dir**: This sets where puppet file templates are found. The default is `$confdir/templates` which should resolve to `/etc/puppet/templates`. For Puppet version 3.5.0 or later setting the template directory is depreciated and will throw a warning.
* **server**: This sets the name of the puppetmaster in the server value in the agent block. The default value is `puppet`.
* **agent**: This enables the puppet agent daemon if set to `true`. The default is `false`. The parameters following this are specific to configuring the agent daemon and will not appear in the `puppet.conf` file if the agent is not enabled.
* **report**: This sets the `report` setting in the agent block. If it is set to true the puppet agent will submit reports. The default value is `true`.
* **report_server**: This sets the reporting server to send reports to. By default this is not set and reports are sent to the puppetmaster.
* **report_port**: This sends the port on the reporting server to submit ports to. By default this setting is omitted. This setting is omitted if no `report_server` is configured.
* **pluginsync**: If this is set to `true` then plugins from modules will be synchronised from the puppetmaster. The default value is `false`.
* **showdiff**: If this is set to `true` file changes will be reported as diffs in the puppet agent reports. The default value is `false`. **WARNING**: Enabling this may expose sensitive information as clear text in puppet reports, this setting should only be used for debugging and testing purposes.
* **environment**: This sets the environment in the agent block. The default value is the same as the `environment` fact provided by facter.
* **dns_alt_names**: Expects an array of names to add to the puppet master's certificate as aliases. The default is undefined which leaves this unconfigured.

## `puppet::conf`

The `puppet::conf` class has been eliminated since version 1.x, and its function rolled into the base `puppet` class.

## `puppet::hiera`

[Hiera](http://projects.puppetlabs.com/projects/hiera) is a simple pluggable hierarchical database which is well suited for storing hierarchical configuration data for Puppet.

The `puppet::hiera` class confirms the Hiera install that came in as a dependency of the puppet package, and manages it's configuration for puppet. It bootstraps the hiera database with a minimal default configuration file (`/etc/puppet/hiera.yaml`) and creates the hiera data store. It makes no attempt to manage or enforce their contents, it only ensures they exist.

When using version control with puppet and hiera, it is recommended that the hiera configuration (`hiera.yaml`) is included in the puppet repository, while the hiera datastore (by default `/etc/puppet/hieradata` with this module) is managed in a separate repository. This segregation allows the puppet configuration to be stored as a public repository, while the hiera data is kept private.

The hiera class currently makes the minimum changes required to suppress warnings that hiera is not configured.

### Parameters

* **ensure**: Sets the ensure state of the heira package and configuration. The default is to match the same state as given the `puppet` class.
* **hiera_config_file**: Sets the path to the file to the hiera configuration in `puppet.conf`. The default is `/etc/puppet/hiera.yaml`.
* **hiera_datadir**: Sets the path to the directory that holds the Hiera data store. The default is `/etc/puppet/hiradata`.
* **hiera_config_source**: If this is set, the string given will be used as a puppet file source for the yaml configuration. The default is `undef` which will use the minimal bootstrap template.
* **hiera_config_content**: If this is set, the string given will be used as a puppet file content for the yaml configuration. The default is `undef` which will use the minimal bootstrap template.
* **hiera_backend**: Sets which back-end format for the Hiera data store, which can either be `yaml` or `json`. The default is `yaml`.
* **hiera_hierarchy**: A list of lists used to create the base Hiera hierarchy.

## `puppet::master`

This class depends on the [Puppetlabs Apache Puppet Module](https://github.com/puppetlabs/puppetlabs-apache) and it's dependencies. Check the [puppetmaster test script](tests/puppetmaster.pp) for more details.

This class can be set up to work with the [Puppetlabs PuppetDB Module](https://github.com/puppetlabs/puppetlabs-puppetdb), check the [puppetmaster with puppetdb test script](tests/pm_with_puppetdb.pp) for more details.

The `puppet::master` class establishes puppet management of the `auth.conf` configuration file and allows the `puppet::auth` resource to add new auth stanzas.

This class installs a Puppetmaster on [Passenger](https://www.phusionpassenger.com/) under [Apache](http://apache.org/) with all the recommended settings. However it may not be entirely compatible with [Apache 2.4](http://httpd.apache.org/docs/2.4/).

### Parameters

* **ensure**: Sets the ensure parameter for the puppetmaster package. The default value is `installed`,
* **puppetmaster_package**: Sets the name of the puppetmaster package to install. Defaults to `puppetmaster_passenger`.
* **puppetmaster_docroot**: Sets the docroot where the puppetmasterd application is installed. The default setting is `/usr/share/puppet/rack/puppetmasterd/public`.
* **servername**: Sets the servername used by the web application. The default value is the FQDN of the node.
* **manifest**: This sets the manifest file or directory (file only for Puppet versions before 3.5.0) that puppet will use as the root manifest. The default is undefined, which removes the manifest setting from `puppet.conf` and the default value `/etc/puppet/manifests/site.pp` is used.
* **report_handlers**: This parameter sets a list of report handlers for the Puppet Master to submit reports to. It should handle a list of handlers, or a formatted string. The default is undefined, which will omit the `reports` setting from the Puppet configuration.
* **reporturl**: This parameter provides a report submission URL for the `http` report handler. If http is missing from the list of report handlers, it will be appended to the list. The default value is undefined, which will omit the `reporturl` setting from the Puppet configuration.
* **storeconfigs**: If this is set to `true` the puppetmaster wills store all puppet clients' configuration, which allows exchanging resources between nodes (i.e. virtual and exported resources). The default value is `false`.
* **storeconfigs_backend**: Setting this will configure the backend terminus for `storedconfigs`. The default omits the setting enabling the default ActiveRecord store. Setting this parameter automatically sets `storeconfigs` to `true.
* **regenerate_certs**: When set to true the `puppet::master` class will regenerate the puppetmaster SSL certificates post install, which [can resolve some SSL issues](#Troubleshooting).
* **environmentpath**: This sets the path to a directory containing a collection of [directory environments](https://docs.puppetlabs.com/puppet/latest/reference/environments_configuring.html). This can use the internal puppet variables like `$confdir`. The default is undefined and leaves this value unconfigured.
* **default_manifest**: This sets the default main manifest for directory environments, any environment that does not set a manifest will use this manifest. The default is undefined, which will revert to the puppet default of `./manifests`.
* **basemodulepaths**: This expects an array of paths for a Puppetmaster to look for Puppet Modules. This list must include `/usr/share/puppet/modules` and will append it if omitted. The default is undefined, which will revert to the puppet default.
* **autosign**: This sets the path to either an `autosign.conf` whitelist of approved domain names and globs, or an executable that can verifiy host names for [policy based autosigning](https://docs.puppetlabs.com/puppet/latest/reference/ssl_autosign.html). The default is undefined, which will use the whitelist in `$confdir/autosign.conf` by default.
* **autosign_conf_path**: This sets the path to the `autosign.conf` whitelist file if the default path of `$confdir/autosign.conf` is not desired.

**NOTE**: Setting the `http` report handler without providing a reporting URL to the `reporturl` parameter may lead to unexpected behaviour by the Puppetmaster.

### Troubleshooting

If there are existing configuration files for the puppetmaster for PuppetDB (i.e. `routes.yaml` and `puppetdb.conf`), the PuppetDB service must be running for the puppetmaster service to start correctly. If PuppetDB is not currently in a running state, these files must be removed, or moved to a backup. This may involve running the `puppetdb ssl-setup` command to install correct certificates to the PuppetDB service.

If the Puppetmaster Rack application won't start, it may have [improperly generated SSL certificates](https://ask.puppetlabs.com/question/365/bad-certificate-error-after-installing-puppetmaster-passenger-on-ubuntu-1204/), which is often caused by changing a server's hostname or the servername of an Apache application. When bootstrapping a puppetmaster the resolution is to stop Apache and the Puppetmaster application, delete the puppet SSL store, regenerate the SSL store, and then restart the Apache web service. This issue is often arises when puppetdb is installed. As root execute the following commands (omit puppetdb commands if it's not installed):

```
$ service apache2 stop
$ service puppetdb stop
$ rm -rf  /var/lib/puppet/ssl
$ puppet master --no-daemonise
$ puppetdb ssl-setup
$ service puppetdb start
$ service apache2 start
```

**WARNING**: This resolution will destroy the ssl store of the Puppetmaster, all clients will need to resubmit certificate requests and have them signed.

This procedure is only suitable for bootstrapping a Puppetmaster. A recommended automation strategy would be to have the certificates pregenerated and stored in a file server, and have them deployed to the server as part of the Puppet automation process. This is outside the scope of this module, but possible if the `regenerate_certs` parameter is set to `false`.

# Resources

These are the resources and types defined by the puppet module.

## `puppet::auth`

The `puppet::auth` resource inserts authorisation stanzas into the `auth.conf` file (the default is `/etc/puppet/auth.conf`). As the order of these entries is important, each instance of `puppet::auth` requires a value for the `order` parameter which matches the form `A100` (a capital letter followed by three digits). Triple zero values (e.g. `A000`, `B000`, `C000`, etc.) are reserved for header comments (defined with the `puppet::auth::header` resource). This `order` parameter defines where the stanza created by a `puppet::auth` instance will be inserted into `auth.conf` and is also used to check for collisions between two instances.

For the details on the `auth.conf` file and its format check the [PuppetLabs documentation](http://docs.puppetlabs.com/guides/rest_auth_conf.htm).

### Usage

This example creates a header comment and an ACL stanza in `auth.conf` that would allow a puppet dashboard server to access the fact inventory:

```puppet
puppet::auth::header{'dashboard':
  order   => 'D',
  content => 'the D block holds ACL declarations for the Puppet Dashboard'
}

puppet::auth{'pm_dashboard_access_facts':
  order       => 'D100',
  path        => '/facts',
  description => 'allow the puppet dashboard server access to facts',
  auth        => 'yes',
  allows      => 'dashboard.example.org',
  methods     => ['find','search'],
}
```

### Parameters

* **order** (required) : This sets the insert location for the ACL stanza.
* **path**: This is the path controlled by the ACL stanza. It defaults to the name of the instance. It can be a path fragment or a regular expression (if `is_regex` is true).
* **description**: If provided, this string is appended to the stanza's header comment.
* **is_regex**: If this parameter is `true`, the path is treated as if it were a regular expression. The default is `false`.
* **environments**: Sets the environment, or a list of environments, in which this ACL stanza is valid. Accepts a string or a list of strings. The default is undefined and omitted from the stanza, which defaults to all environments.
* **methods**: Sets the method, or a list of methods, that the ACL stanza uses. Accepts a string or a list of strings. Valid methods are; `find`, `search`, `save`, and `destroy`. The default is undefined and omitted from the stanza, which permits all methods.
* **auth**: Sets the auth type for this ACL stanza. Valid auth types are; `yes` or `on`, `no` or `off`, or `any`. The default is undefined and omitted from the stanza, which defaults to `yes`.
* **allows**: This sets an allow pattern, or list of allow patterns, used by the ACL stanza. Accepts a string or a list of strings. These strings can be host names, certificate names, `*` (all nodes), or regular expressions. The default is undefined and omitted from the stanza.
* **denys**: This sets an deny pattern, or list of deny patterns, used by the ACL stanza. Accepts a string or a list of strings. These strings can be host names, certificate names, `*` (all nodes), or regular expressions. The default is undefined and omitted from the stanza. The deny entry is permitted, but has no effect.
* **allow_ips**: This sets an allow pattern, or list of allow patterns, that are IP address based and used by the ACL stanza. Accepts a string or a list of strings. These strings can be an IP address, a glob (e.g `192.168.0.*`) representing a group of IP addesses, or a CDIR block (e.g. `10.0.0.0/24`) representing a group of IP addresses. The default is undefined and omitted from the stanza.
* **deny_ips**: This sets an deny pattern, or list of deny patterns, that are IP address based and used by the ACL stanza. Accepts a string or a list of strings. These strings can be an IP address, a glob (e.g `192.168.0.*`) representing a group of IP addesses, or a CDIR block (e.g. `10.0.0.0/24`) representing a group of IP addresses. The default is undefined and omitted from the stanza. The deny_ip entry is permitted, but has no effect.

## `puppet::auth::header`

The `puppet::auth::header` resource inserts header comments into the `auth.conf` file (the default is `/etc/puppet/auth.conf`). As the order of these entries is important, each instance of `puppet::auth::header` requires a value for the `order` parameter as a capital letter (i.e A to Z). This `order` parameter defines where the header comment created by a `puppet::auth` instance will be inserted into `auth.conf` and is also used to check for collisions between two instances. The following header locations have already been used; A,M,Q, and X.

### Parameters

* **order** (required) : This sets the insert order of the header comment.
* **content** (required) : This is the text for the header comment.

## `puppet::autosign`

The `puppet::autosign` resource inserts it's name as a whitelist entry into the `autosign.conf` file given by the `autosign_conf_path` paramter of the `puppet::master` class. This class has no parameters. This class performs a regular expression validation of the name which should be of the form of a fully qualified domain name, but can use a leading `*` prefix to as a glob matcher for sub-domains.

### Usage

```puppet
puppet::autosign{'*.local': }
puppet::autosign{'puppet.example.com': }
```

## `puppet::fileserver`

The `puppet::fileserver` resource inserts fileserver declarations into the `fileserver.conf` file. By default these entries will be entered in alphabetical order by their name. More details on the the `fileserver.conf` file can be found in the [PuppetLabs Documentation](http://docs.puppetlabs.com/puppet/latest/reference/config_file_fileserver.html).

The `puppet::fileserver` resource does *not* create the path for the file server.

When setting the `path` parameter for `puppet::fileserver` there are some special matchers available for the path:

* `%H` The node's certname (i.e. the name given in the certificate used to identify the node to the puppetmaster).
* `%h` The portion of the node's certname before the first dot. (Usually the node's short hostname.)
* `%d` The portion of the node's certname after the first dot. (Usually the node's domain name.)

### Usage

As setting the ACL in `fileserver.conf` is now depreciated. the `puppet::fileserver` always sets the ACL rules to 'allow all' (actually `allow *`) this resources needs to be paired with a `puppet::auth` declaration. Hence correct usage in a node manifest after setting up `puppet::master` to provide a private file server that directs each node to a directory determined by its certname would be:

```puppet

file {'/private':
  ensure => 'directory',
}

puppet::fileserver{'private':
  path        => '/private/%H',
  description => 'a private file share containing node specific files',
  require     => File['private'],
}

puppet::auth{'private_fileserver:
  order       => 'A550',
  description => 'allow authenticated nodes access to the private file share',
  path        => '/private',
  allow       => '*',
}
```

### Parameters

* **path** (required) : This is the path to the directory containing the files for the file server.
* **description** (required) : This is a description of purpose of the file sever.
* **order**: This changes the insertion order of the file server declaration in `fileserver.conf`. The default is to use the `name` parameter.

# Alternaive Repositories

This module does not manage repositories, but should install software from any repository (such as the Puppetlabs [Apt](http://apt.puppetlabs.com/) and [Yum](http://yum.puppetlabs.com/) repositories) configured on a machine running the puppet agent.

Puppet has a native [resource for yum](http://docs.puppetlabs.com/references/latest/type.html#yumrepo), and the [Puppetlabs Apt Module](https://github.com/puppetlabs/puppetlabs-apt) provides a suitable resource for managing apt repositories.

# Dependencies

## Required

* [puppetlabs-stdlib](https://github.com/puppetlabs/puppetlabs-stdlib)
* [puppetlabs-concat](https://github.com/puppetlabs/puppetlabs-concat)

## Optional

* [puppetlabs-apache](https://github.com/puppetlabs/puppetlabs-apache): This module is only a dependency when using the `puppet::master` class. The current master from the github repository is required until 0.10.0 is released.

# References

There are other Puppet modules that can be used for puppet and puppetmaster and I may have borrowed components from them. Each has been considered, but found lacking in some area:
* [puppetlabs\puppetlabs-puppet](https://github.com/puppetlabs/puppetlabs-puppet): Is incomplete and not in active development
* [stephenrjohnson\puppetlabs-puppet](https://github.com/stephenrjohnson/puppetlabs-puppet): Complete, but bundles in the Puppet Dashboard, uses an out of date version of [puppetlabs-apache](apache), explicitly configures Apache and modules.
* [ghoneycutt/puppet-module-puppet](https://github.com/ghoneycutt/puppet-module-puppet): Complete, but bundles in the Puppet Dashboard, uses an out of date version of [puppetlabs-apache](apache), and explicitly configures Apache and modules.

Bundling Puppet Dashboard is undesirable as it is a separate application from puppet, hence should be managed separately.

Explicitly configuring Apache, it's modules, or Passenger is not desirable as it makes the Apache configuration too inflexible and can make it difficult to serve other web applications from the same server.

# Licensing

Written by Aaron Hicks (hicksa@landcareresearch.co.nz) for the New Zealand eScience Infrastructure.

# Attribution

## puppet-blank

This module is derived from the puppet-blank module by Aaron Hicks (aethylred@gmail.com)

* https://github.com/Aethylred/puppet-blank

This module has been developed for the use with Open Source Puppet (Apache 2.0 license) for automating server & service deployment.

* http://puppetlabs.com/puppet/puppet-open-source/

# Gnu General Public License

This file is part of the NeSI Puppet Puppet module.

The NeSI Puppet Puppet module is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.

The NeSI Puppet Puppet module is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more details.

You should have received a copy of the GNU General Public License along with the NeSI Puppet Puppet module.  If not, see <http://www.gnu.org/licenses/>.