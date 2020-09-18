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
	strict.set off
	msg.prefix.set "$PRG"
	
main() {
	local -a args=()
	while (( $# )); do
		case "$1" in
			-v|--verbose)		verbose.set on;;
			-q|--quiet)			verbose.set off;;
			-V|--version)		msg "$(version.set)"; return 0;;
			-h|--help)			usage; return 0;;
			-?|--*)					msg.err "Invalid option [$1]"; return 22;;
			*)							args+=( "$1" );;
											#msg.err "Invalid argument [$1]"; return 22;;
		esac
		shift
	done
	msg "${args[@]:-}"
	
	
	
	
}

# shellcheck disable=SC2086
cleanup() {
	local -i err=$?
	[[ -z ${1:-} ]] && err=$1
	((err > 1)) && errno $err
	exit $err
}

usage() {
	cat <<-usage
		Script  : 
		Desc    : 
		Synopsis: $PRG 
		            [-v|--verbose] [-q|--quiet] 
	usage
	return 0
}

main "$@"
#fin
