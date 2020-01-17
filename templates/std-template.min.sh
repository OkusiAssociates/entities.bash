#!/bin/bash
source entities.bash || { echo >&2 "Could not open entities.bash!"; exit 1; }
	strict.set on
	verbose on

main() {
#	exit_if_not_root
#	exit_if_already_running
	
	
	
}


cleanup() {
	[[ $1 == '' ]] && exitcode=$? || exitcode=$1
	lockfiles.delete.all
	exit $exitcode
}

usage() {
	cat <<-usage
		Usage: $PRG [[-v|--verbose] [-q|--quiet]] [-h|--help]
		
	usage
	[[ $1 == 'exit' ]] && exit 1
}

main "$@"
#fin
