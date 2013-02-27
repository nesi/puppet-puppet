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

<a rel="license" href="http://creativecommons.org/licenses/by-sa/3.0/"><img alt="Creative Commons Licence" style="border-width:0" src="http://i.creativecommons.org/l/by-sa/3.0/88x31.png" /></a><br />This work is licensed under a <a rel="license" href="http://creativecommons.org/licenses/by-sa/3.0/">Creative Commons Attribution-ShareAlike 3.0 Unported License</a>