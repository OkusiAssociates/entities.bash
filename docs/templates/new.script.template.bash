#!/bin/bash
# #! shellcheck disable=SC
source entities || exit 2
	trap.set on
	strict.set on
	version.set '0.1'
	msg.prefix.set "$PRG"
	
	# global vars
	
	
# main
main() {
	local -a args=()
	while (( $# )); do
		case "$1" in
			#-|--);;
			-v|--verbose)		msg.verbose.set on;;
			-q|--quiet)			msg.verbose.set off;;
			-V|--version)		version.set; return 0;;
			-h|--help)			usage; return 0;;
			-?|--*)					msg.err "Invalid option [$1]"; return 22;;
			*)							args+=( "$1" );;
											#msg.err "Invalid argument [$1]"; return 22;;
		esac
		shift
	done

	# code
	msg "${args[@]:-}"
	
	
	
}

# exit trap set to cleanup
# shellcheck disable=SC2086
cleanup() {
	local -i err=$?
	[[ -z ${1:-} ]] && err=$1
	#...
	((err > 1)) && errno $err
	exit $err
}

usage() {
# 0#######:#|##|############|#################################################78
	cat <<-etx
	Script  : 
	Desc    : 
	Synopsis: $PRG    [-v][-q] [-V] [-h]
	        :  -|--           
	        :  -|--           
	        :  -v|--verbose   Turn on msg verbose. (default)
	        :  -q|--quiet     Turn off msg verbose.
	        :  -V|--version   Print version.
	        :  -h|--help      This help.
	Example : 
	etx
# 0#######:#|##|############|#################################################78
	return 0
}

main "$@"
#fin
