define puppet::hiera::make_hierarchy {
	file{"${puppet::install::hiera_datadir}/${name}.yaml":
		ensure	=> file,
	}
}