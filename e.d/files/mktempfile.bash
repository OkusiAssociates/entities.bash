#!/bin/bash
#! shellcheck disable=SC2174,SC2154
#X Function: mktempfile 
#X         : Make a temporary file. 
#X         : Template format is:
#X         :    /{TMPDIR}/{subdir}/{PRG}_{RAND}
#X Synopsis: mktempfile [base_subdir]
#X         : Return value of '' means failure.
#X See Also: tmpdir.set
mktempfile() {
	local TmpDir TmpFile
	TmpDir="${TMPDIR:-/tmp}/${1:-entities}"
	mkdir --mode=0770 -p "${TmpDir}" || { echo ''; return; }
	TmpFile="$(mktemp "${TmpDir}/${PRG:-$(basename "$0")}_XXXX")"
	echo "$TmpFile"
	return 0
}
declare -fx mktempfile

#X Function: tmpdir.set
#X Desc    : Sets TMPDIR location, with optional fallback if first 
#X         : option not writable. Final fallback is always /tmp.
#X         :
#X Synopsis: tmpdir.set ["tmpdir" ["fallbackdir"]] 
#X         :
#X Example : tmpdir.set '/run/entities' '/tmp/entities'
#X         : tmpdir="$(tmpdir.set)"
#X         :
#X See Also: mktempfile
declare -x TMPDIR="${TMPDIR:-/tmp}"
tmpdir.set() {
	if (( $# )); then
		local tmp=$1
		# fail silently if not found; do not change TMPDIR
		if [[ ! -d "$tmp" ]]; then
			mkdir -m 777 -p "$tmp" || { echo ''; return 1; }
		fi
		if [[ -w "$tmp" ]]; then
			TMPDIR="$tmp"
		elif [[ -n "${2:-}" ]]; then
			if [[ -d "$2" ]]; then
				mkdir -m 777 -p "$2" || { echo ''; return $?; }
			fi
			if [[ -w "$2" ]]; then
				TMPDIR="$2"
			else
				echo ''
				return 1
			fi
		fi
	fi
	echo "$TMPDIR:-/tmp"
}
declare -fx 'tmpdir.set'

#fin
