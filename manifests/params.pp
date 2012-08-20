# This manifests sets the default parameters for installing puppet


class puppet::params{
	case $operatingsystem {
		Ubuntu:{
			$puppet_package = 'puppet'
		}
	}
}