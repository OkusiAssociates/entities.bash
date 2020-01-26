#!/bin/bash
source entities.bash || exit 1
	version.set '0.1.420.0.0'
	verbose.set on
	strict.set on

main() {
	is.root || { msg.err "Require root access."; exit 1; }
	
	
	
}

cleanup() {
	if [[ "${1:-}" == '' ]];	then exitcode="$?"
														else exitcode="$1"
	fi
	exit "$exitcode"
}

usage() {
	cat <<-usage
		Usage: $PRG 
		
	usage
	[[ ${1:-} == 'exit' ]] && exit 1
	return 0
}

main "$@"
#fin
