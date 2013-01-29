# This contains the parameters for the puppet::hiera classes

class puppet::hiera::params{
		case $operatingsystem {
		Ubuntu:{
			$hiera_package = 'heira-puppet'
		}
}