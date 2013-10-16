# puppet-puppet

A Puppet module for managing puppet and puppetmaster

# Introduction

While working on the dynaguppy project it was decided that puppet will have to install and configure puppetmaster. As puppetmaster shares configuration files (`/etc/puppet/puppet.conf` in particular), and puppet modules should not attempt to manage files *between* modules, a single puppet and puppetmaster module would be required.

...thus we get puppet recursivley puppetising puppet, which can only end in wonderous singularity, or firey loops of oblivion.

# To install into puppet

Clone into your puppet configuration in your `puppet/modules` directory:

 git clone git://github.com/nesi/puppet-puppet.git puppet

Or if you're managing your Puppet configuration with git, in your `puppet` directory:

    git submodule add git://github.com/nesi/puppet-puppet.git modules/puppet --init --recursive
    cd modules/puppet
    git checkout master
    git pull
    cd ../..
    git commit -m "added puppet submodule from https://github.com/nesi/puppet-puppet"

It might seem bit excessive, but it will make sure the submodule isn't headless...

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

    $ tree spec/fixtures/augeas/
    spec/fixtures/augeas/
    `-- etc
        `-- ssh
            `-- sshd_config

# Gnu General Public License

This file is part of the NeSI Puppet Puppet module.

The NeSI Puppet Puppet module is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.

The NeSI Puppet Puppet module is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more details.

You should have received a copy of the GNU General Public License along with the NeSI Puppet Puppet module.  If not, see <http://www.gnu.org/licenses/>.