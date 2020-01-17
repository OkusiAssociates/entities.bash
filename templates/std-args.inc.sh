
	# handle options
	cmd=()
	while (($#)); do
		case "$1" in
			-h|-?|--help)		usage exit	;;
			-v|--verbose)		VERBOSE=1 ;;
			-q|--quiet)			VERBOSE=0 ;;
			--myopt)
				shift
				myvar=$1
				;;
			*)
				# for scripts that use lists of non-option arguments.
				# delete references to cmd if this not used.
				cmd+=( "$1" ) 
				# for scripts that do not use non-option arguments, 
				# include msgdie to exit with error message.
				# may want to remind user of usage first.
				#usage
				#msgdie log "Bad command line argument '$1'!"
				;;
		esac
		shift
	done
