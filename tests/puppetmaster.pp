# This file is part of the puppet Puppet module.
#
#     The puppet Puppet module is free software: you can redistribute it and/or modify
#     it under the terms of the GNU General Public License as published by
#     the Free Software Foundation, either version 3 of the License, or
#     (at your option) any later version.
#
#     The puppet Puppet module is distributed in the hope that it will be useful,
#     but WITHOUT ANY WARRANTY; without even the implied warranty of
#     MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#     GNU General Public License for more details.
#
#     You should have received a copy of the GNU General Public License
#     along with the puppet Puppet module.  If not, see <http://www.gnu.org/licenses/>.
#
# Set up Puppet
include puppet
include puppet::conf
include puppet::hiera

# Set up apache
include apache
class {'apache::mod::passenger':
  passenger_high_performance    => 'off',
  passenger_max_pool_size       => 12,
  passenger_pool_idle_time      => 1500,
  # passenger_max_requests        => 1000,
  passenger_stat_throttle_rate  => 120,
  rack_autodetect               => 'off',
  rails_autodetect              => 'off',
}

# Set up the puppetmaster
include puppet::master