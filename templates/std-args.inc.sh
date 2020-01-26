
	cmd=()
	while (($#)); do
		case "$1" in
			-V|--version)	echo "$PRG $(version.set)"; exit 0;;
			-h|--help)		usage exit 1;;
			-v|--verbose)	verbose.set on;;
			-q|--quiet)		verbose.set off;;
			*)						cmd+=( "$1" );;
		esac
		shift
	done
