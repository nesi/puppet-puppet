# puppet-puppet

A Puppet module for installing, configuring and managing puppet, puppetmaster, and hiera.

# Introduction

While working on the [dynaguppy](https://github.com/Aethylred/dynaguppy) project a module was required to install and configure puppet, puppetmaster and hiera. As the puppet agent and puppetmaster share configuration files (`/etc/puppet/puppet.conf` in particular), and puppet modules should not attempt to manage files *between* modules, a single puppet and puppetmaster module would be required. Hiera is now installed with Puppet as a dependency, it is appropriate that hiera is condfigured with this module.

...thus we get puppet recursivley puppetising puppet, which can only end in wonderous singularity, or firey loops of oblivion.

# Dependencies

* [puppetlabs-sdlib](https://github.com/puppetlabs/puppetlabs-stdlib)
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