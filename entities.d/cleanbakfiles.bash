#!/bin/bash

#X Function: cleanbakfiles cln
#X         : this function is also a command line accessabe script
#X Desc    : Remove all *~ files recursively from current directory.
cleanbakfiles() {
	usage() {
		echo "cleanbackfiles [-m|--maxdepth depth] [-q|--quiet] [dir]..."
	}
	local -i maxdepth=16 verbose=1
	local -a adir
	while (($#)); do
		case $1 in
			-h|--help)			usage; return ;;
			-m|--maxdepth)	shift; maxdepth=${1:-1} ;;
			-q|--quiet)			verbose=0 ;;
			*)							adir+=( "$1" ) ;;
		esac
		shift
	done
	((${#adir[@]})) || adir=( "$(pwd)" ) 

	for dir in "${adir[@]}"; do
		dir="$(readlink -f "$dir")"
		if [[ -d "$dir" ]]; then 
			((verbose)) && echo "Cleaning ${dir}..."
			/usr/bin/find "$dir" -maxdepth $maxdepth -name "*~"	-type f -exec rm {} \;
			/usr/bin/find "$dir" -maxdepth $maxdepth -name "DEADJOE" -type f -exec rm {} \;
		else
			echo >&2 "Directory $dir not found!"
		fi
	done	
	return 0
}
declare -fx cleanbakfiles

#fin
