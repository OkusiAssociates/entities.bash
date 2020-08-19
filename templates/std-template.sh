#!/bin/bash
#X Function|Global|Local|Script: 
#X Desc    : 
#X Synopsis: 
#X Options :
#X Example : 
#X Depends :
#X See Also:
source entities || exit 1

	version.set '0.1'
	verbose.set "$([ -t 0 ] && echo 1 || echo 0)"
	trap.set on
	strict.set on

main() {
	declare -i i=0
	declare -a arg=()
	while (($#)); do
		case "$1" in
			--help|-h)			usage; exit 0;;
			--version|-V)		msg "$PRG $(version.set)"; exit 0;;
			--verbose|-v)		verbose.set on;;
			--quiet|-q)			verbose.set off;;
			-*|--*)					msg.die "$PRG.error Invalid option [$1]";;
			*)							arg+=( "$1" );;
											#msg.die "$PRG.error Bad argument [$1]";;
		esac
		shift
	done
	msg.sys ${arg[@]}
	
	
	
}


cleanup() {
	[[ "${1:-}" == '' ]] && exit $?
	exit $1
}

usage() {
	cat <<-usage
		Usage: $PRG [[--verbose|-v] [--quiet|-q]] 
		       $PRG [--help|-h]
		
	usage
	exit 1
}

main "$@"
#fin
