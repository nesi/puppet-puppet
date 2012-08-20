# This manifests sets the default parameters for installing puppet

case $operatingsystem {
	Ubuntu:{
		$puppet_package = 'puppet',
	}
}