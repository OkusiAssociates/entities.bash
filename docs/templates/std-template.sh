#!/bin/bash
#X Function|Global|Local|Script: 
#X Desc    : 
#X Synopsis: 
#X Options :
#X Example : 
#X Depends :
#X See Also:
source entities || exit 2
	version.set '0.1'
	verbose.set on
	trap.set on
	strict.set on

main() {
	declare -i i=0
	declare -a args=()
	while (( $# )); do
		case "$1" in
			-v|--verbose)		verbose.set on;;
			-q|--quiet)			verbose.set off;;
			-V|--version)		msg "$PRG $(version.set)"; exit 0;;
			-h|--help)			usage; return 0;;
			-?|--*)					msg.err "Invalid option [$1]"; return 1;;
			*)							args+=( "$1" );;
											#msg.err "Invalid argument [$1]"; return 1;;
		esac
		shift
	done
	msg "${args[@]:-}"
	
	
	
}


cleanup() {
	local -i err=$?
	[[ -z ${1:-} ]] && err=$1
	exit $err
}

usage() {
	cat <<-usage
		Usage: $PRG 
		         [-v|--verbose] [-q|--quiet] 
		         [-h|--help]
	usage
	exit 1
}

main "$@"
#fin
