#!/bin/bash
#X Function: mktempfile 
#X         : Make a temporary file located in /tmp/entities 
#X         : Template format is /tmp/{base_subdir}/{$PRG|basename_script}_XXXX
#X Synopsis: mktempfile [base_subdir]
#X         : Return value of '' means failure.
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
#X Synopsis: tmpdir.set ["tmpdir"]
#X Example : tmpdir.set '/run/entities
#X         : tmpdir="$(tmpdir.set)"
declare -x TMPDIR="${TMPDIR:-/tmp}"
tmpdir.set() {
	if (( $# )); then
		tmp="${1}"
		mkdir -p "$tmp" && cd "$tmp" && TMPDIR="$(pwd)" && cd -
	fi
	echo "$TMPDIR:-/tmp"
}
declare -fx 'tmpdir.set'

#fin
