define puppet::hiera::make_hierarchy(
	$yaml,
	$json
) {

	if $yaml {
		file{"${puppet::install::hiera_datadir}/${name}.yaml":
			ensure	=> file,
		}
	}

	if $json {
		file{"${puppet::install::hiera_datadir}/${name}.json":
			ensure	=> file,
		}
	}
}