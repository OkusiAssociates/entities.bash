#!/bin/bash
#X Function: mktempfile
#X         : make a temporary file located in /tmp/entities 
#X         : template format is /tmp/entities/{$PRG|basename_script}_XXXX
#X         : 
#X         : 
function mktempfile() {
	TmpDir="${TMPDIR:-/tmp}/entities"
	mkdir -p "${TmpDir}" || return 1
	TmpFile="$(mktemp "${TmpDir}/${PRG:-$(basename "$0")}_XXXX")"
	echo "$TmpFile"
	return 0
}
#fin
