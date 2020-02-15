#!/bin/bash

#X Function: cleanbakfiles cln
#X         : this function is also a command line accessabe script
#X Desc    : Remove all *~ files recursively from current directory.
cleanbakfiles() {
	local dir="${1:-}"
	if ((${#dir})); then dir="$(readlink -f "$dir")"
 									else dir="$(pwd)"
	fi
	if [[ -d "$dir" ]]; then 
		echo "Cleaning ${dir}..."
		/usr/bin/find "$dir" -name "*~" 			-type f -exec rm {} \;
		/usr/bin/find "$dir" -name "DEADJOE" -type f -exec rm {} \;
	else
		echo >&2 "Directory $dir not found!"
	fi
	return 0
}
#fin
