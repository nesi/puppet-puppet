# NeSI Puppet Puppet Module

[![Build Status](https://travis-ci.org/nesi/puppet-puppet.png?branch=refactor)](https://travis-ci.org/nesi/puppet-puppet)

NeSI Puppet Puppet Module is a Puppet module for installing, configuring and managing puppet, puppetmaster, and hiera.

# Introduction

While working on the [dynaguppy](https://github.com/Aethylred/dynaguppy) project a module was required to install and configure puppet, puppetmaster and hiera. As the puppet agent and puppetmaster share configuration files (`/etc/puppet/puppet.conf` in particular), and puppet modules should not attempt to manage files *between* modules, a single puppet and puppetmaster module would be required. Hiera is now installed with Puppet as a dependency, it is appropriate that hiera is condfigured with this module.

...thus we get puppet recursivley puppetising puppet, which can only end in wonderous singularity, or firey loops of oblivion.

# Usage

## Default Usage

The following puppet snippet will install puppet and enforce the default puppet configuration:  
```puppet
include puppet
include puppet::conf
```

## The `puppet` class

The `puppet` class installs puppet from packages available to whichever repositories have been [previously configured](#Alternative Repositories). The `puppet` class can be called without parameters to install with defaults, or as a parametric class.

### Parameters

* **ensure**: The ensure parameter specifies the installation state of the puppet configuration. If it is `installed` or a valid semantic version number, Puppet will be installed. If it is `absent` then Puppet will be removed, including any configuration files and directories that were set up. The default value is `installed`.
* **puppet_package**: Specifies the name of the package used to install Puppet. The default value is `puppet`.
* **user**: Specifies the puppet user account. The default value is `puppet`.
* **gid**: The primary group identity of the puppet user. The default value is `puppet`.
* **user_home**: Sets the home directory for the puppet user. The default value is `/var/lib/puppet`.
* **conf_dir**: Sets the directory where the puppet configuration file is stored. The default is `/etc/puppet`.
* **environments**: If this is set to true, the puppet configuration will be set to enable the use of puppet environments. The default value is `true`.

## The `puppet::conf` class

The `puppet::conf` class manages the puppet configuration. It is dependent on the `puppet` class and requires that this be called first. The `puppet::conf` class can be called with no parameters for the default values, or called as a parametric class.

### Parameters

The parameters for `puppet::conf` correspond to setting in the [puppet configuration file](http://docs.puppetlabs.com/guides/configuring.html) (usually `/etc/puppet/puppet.conf`). It uses [augeas](http://augeas.net/) to manage the puppet configuration file.

* **environment**: This sets the environment in the agent block. The default value is the same as the `environment` fact provided by facter.
* **pluginsync**: If this is set to `true` then plugins from modules will be used. The default value is `true`, and it is recommended that  it is not changed.
* **puppetmaster**: This sets the name of the puppetmaster in the server value in the agent block. The default value is `puppet`.
* **report**: This sets the `report` setting in the agent block. If it is set to true the puppet agent will send reports to the puppetmaster. The default value is `true`.
* **show_diff**: Sets the `show_diff` setting in the agent block, if true the puppet agent will include file diffs in puppet reports. **NOTE:** this may expose security settings in clear text as part of a puppet agent report. The default value is `undef` which will ensure this setting is removed.
* **var_dir**: This sets the puppet working directory that contains cached data, configurations and reports. The default is `/var/lib/puppet`.
* **ssl_dir**: This sets the directory where puppet stores SSL state, including certificates and keys. The default is `/var/lib/puppet/ssl`.
* **run_dir**: This sets the `rundir` setting in the `agent` block of the puppet conf. The default setting is `/var/run/puppet`.
* **fact_path**: This sets the directory where facter facts are stored. The default is `/var/lib/puppet/facter`.
* **template_dir**: This sets where puppet file templates are found. The default is `$confdir/templates` which should resolve to `/etc/puppet/templates`.

# Alternative Repositories

This module does not manage repositories, but should install software from any repository (such as the Puppetlabs [Apt](http://apt.puppetlabs.com/) and [Yum](http://yum.puppetlabs.com/) repositories) configured on a machine running the puppet agent.

Puppet has a native [resource for yum](http://docs.puppetlabs.com/references/latest/type.html#yumrepo), and the [Puppetlabs Apr Module](https://github.com/puppetlabs/puppetlabs-apt) provides a suitable resource for managing apt repositories.

# Dependencies

* [puppetlabs-apache](apache): This module is only a dependency when using the `puppet::master` class.
[apache]:https://github.com/puppetlabs/puppetlabs-apache

# References

There are other Puppet modules that can be used for puppet and puppetmaster and I may have borrowed components from them. Each has been considered, but found lacking in some area:
* [puppetlabs\puppetlabs-puppet](https://github.com/puppetlabs/puppetlabs-puppet): Is incomplete and not in active development
* [stephenrjohnson\puppetlabs-puppet](https://github.com/stephenrjohnson/puppetlabs-puppet): Complete, but bundles in the Puppet Dashboard, uses an out of date version of [puppetlabs-apache](apache), explicitly configures Apache and modules.
* [ghoneycutt/puppet-module-puppet](https://github.com/ghoneycutt/puppet-module-puppet): Complete, but bundles in the Puppet Dashboard, uses an out of date version of [puppetlabs-apache](apache), and explicitly configures Apache and modules.

Bundling Puppet Dashboard is undesireable as it is a separate application from puppet, hence should be managed separately.

Explicitly configuring Apache, it's modules, or Passenger is not desirable as it makes the Apache configuration too inflexible and can make it difficult to serve other web applications from the same server.

# Licensing

Written by Aaron Hicks (hicksa@landcareresearch.co.nz) for the New Zealand eScience Infrastructure.

# Attribution

## puppet-blank

This module is derived from the puppet-blank module by Aaron Hicks (aethylred@gmail.com)

* https://github.com/Aethylred/puppet-blank

This module has been developed for the use with Open Source Puppet (Apache 2.0 license) for automating server & service deployment.

* http://puppetlabs.com/puppet/puppet-open-source/

## rspec-puppet-augeas

This module includes the [Travis](https://travis-ci.org) configuration to use [`rspec-puppet-augeas`](https://github.com/domcleal/rspec-puppet-augeas) to test and verify changes made to files using the [`augeas` resource](http://docs.puppetlabs.com/references/latest/type.html#augeas) available in Puppet. Check the `rspec-puppet-augeas` [documentation](https://github.com/domcleal/rspec-puppet-augeas/blob/master/README.md) for usage.

This will require a copy of the original input files to `spec/fixtures/augeas` using the same filesystem layout that the resource expects:  
```
$ tree spec/fixtures/augeas/
spec/fixtures/augeas/
`-- etc
    `-- ssh
        `-- sshd_config
```

# Gnu General Public License

This file is part of the NeSI Puppet Puppet module.

The NeSI Puppet Puppet module is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.

The NeSI Puppet Puppet module is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more details.

You should have received a copy of the GNU General Public License along with the NeSI Puppet Puppet module.  If not, see <http://www.gnu.org/licenses/>.