define puppet::hiera::heira_make_hierarchy {
	file{"${puppet::install::hiera_datadir}/${name}.yaml":
		ensure	=> file,
	}
}