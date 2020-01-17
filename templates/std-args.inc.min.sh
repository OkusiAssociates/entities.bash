
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
				cmd+=( "$1" ) 
				#diemsg log "Bad command line argument '$1'!"
				;;
		esac
		shift
	done
