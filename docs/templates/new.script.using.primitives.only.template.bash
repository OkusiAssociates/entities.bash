#!/bin/bash
#! shellcheck disable=SC2034
# entities 'primitives' for stand-alone scripts
declare -- _ent_0 PRG PRGDIR; PRG=$(basename "${_ent_0}"); PRGDIR=$(dirname "${_ent_0}")
VERSION='0.1';	version.set() { (($#)) && VERSION="$*" || echo "$VERSION"; }
VERBOSE=1;  verbose.set() { (($#)) && VERBOSE=$(onoff "$*") || echo "$VERBOSE"; }
trap '{ cleanup $?; }' EXIT; trap.set() { :; }
_ent_STRICT=0; strict.set() { (($#)) || { echo -n "${_ent_STRICT}"; return 0; }; local opt='+'; _ent_STRICT=$(onoff "${1}" ${_ent_STRICT}); ((_ent_STRICT)) && opt='-'; set ${opt}o errexit ${opt}o nounset ${opt}o pipefail; return 0; }
PREFIX="$PRG"; msg.prefix.set() { (($#)) && PREFIX="$*" || echo "$PREFIX"; }
msg() { ((VERBOSE)) || return 0; while read -r l; do echo "$PREFIX:" "$l"; done <<<"$@"; }
msg.info() { ((VERBOSE)) || return 0; while read -r l; do echo "$PREFIX:" "$l"; done <<<"$@"; }
msg.warn() { ((VERBOSE)) || return 0; while read -r l; do echo >&2 "$PREFIX: !!! " "$l"; done <<<"$@"; }
msg.err() { while read -r l; do echo >&2 "$PREFIX: *** " "$l"; done <<<"$@"; }
msg.sys() { systemd-cat -t "$PREFIX" -p err  echo "$@"; echo "$@"; }
msg.die() { msg.sys "$@"; exit 1; }
exit_if_already_running() { for p_ in $(pidof -x "$PREFIX"); do [ "${p_}" -ne "$$" ] && msg.die "$0 is currently running."; done; }
onoff() {	local o="${1:-0}"; case "${o,,}" in 	on|1) o=1;; off|0) o=0;;	*) o=0; (( $# > 1 )) && o=$(( ${2} ));; esac;	echo -n $((o)); }
trim() { local v="$*";v="${v#"${v%%[![:space:]]*}"}";v="${v%"${v##*[![:space:]]}"}";echo -n "$v"; }
# end entities 'primitives'

	trap.set on
	strict.set off
	version.set '0.1'
	msg.prefix.set "$PRG"
	
	# global vars
	
# main
main() {
	local -a args=()
	while (( $# )); do
		case "$1" in
			#-|--);;
			-v|--verbose)		verbose.set on;;
			-q|--quiet)			verbose.set off;;
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
	Script:Function: 
	Desc    : 
	Synopsis: $PRG    [-v][-q] [-V] [-h]
	        :  -|--)      
	        :  -|--)      
	        :  -v|--verbose   turn on  msg verbose. (default)
	        :  -q|--quiet     turn off msg verbose.
	        :  -V|--version   print version.
	        :  -h|--help      this help.
	Example : 
	etx
# 0#######:#|##|############|#################################################78
	return 0
}

main "$@"
#fin
