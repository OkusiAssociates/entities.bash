#!/bin/bash
#X Function: mktempfile
#X         : make a temporary file located in /tmp/entities 
#X         : template format is /tmp/{base_subdir}/{$PRG|basename_script}_XXXX
#X Synopsis: mktempfile [base_subdir]
#X         : return value of '' means failure.
mktempfile() {
	local TmpDir TmpFile
	TmpDir="${TMPDIR:-/tmp}/${1:-entities}"
	mkdir --mode=0770 -p "${TmpDir}" || { echo ''; return; }
	TmpFile="$(mktemp "${TmpDir}/${PRG:-$(basename "$0")}_XXXX")"
	echo "$TmpFile"
}
declare -fx mktempfile

declare -x TMPDIR="${TMPDIR:-/tmp}"
tmpdir.set() {
	if (( $# )); then
		tmp="${1}"
		mkdir -p "$tmp" && cd "$tmp" && TMPDIR="$(pwd)"
	fi
	echo "$TMPDIR:-/tmp"
}
declare -fx tmpdir.set

#fin
