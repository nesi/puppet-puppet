# Class: puppet
#
# This manifests does the sanity checking in preparation of installing
# the puppet package and configure the puppet agent
#
# Parameters:
#
# Actions:
#
# Requires:
#
# Sample Usage:
#
# Note, the .json Hiera backend is enabled by default as the usual .yaml backend
# can not be manipulated with augeas.

# This file is part of the puppet Puppet module.
#
#     The puppet Puppet module is free software: you can redistribute it and/or
#     modify it under the terms of the GNU General Public License as published
#     by the Free Software Foundation, either version 3 of the License, or
#     (at your option) any later version.
#
#     The puppet Puppet module is distributed in the hope that it will be
#     useful, but WITHOUT ANY WARRANTY; without even the implied warranty
#     of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#     GNU General Public License for more details.
#
#     You should have received a copy of the GNU General Public License
#     along with the puppet Puppet module.
#     If not, see <http://www.gnu.org/licenses/>.

# [Remember: No empty lines between comments and class definition]
class puppet (
  $ensure               = 'present',
  $pluginsync           = false,
  $storeconfigs         = false,
  $user_shell           = false,
  $environments         = false,
  $puppetmaster         = false
){

  include puppet::params

  class{'puppet::install':
    ensure              => $ensure,
    pluginsync          => $pluginsync,
    storeconfigs        => $storeconfigs,
    user_shell          => $user_shell,
    environments        => $environments,
    puppetmaster        => $puppetmaster,
  }

}