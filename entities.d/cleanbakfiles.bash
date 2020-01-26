#!/bin/bash

#X Function: cleanbakfiles cln
#X         : this function is also a command line accessabe script
#X Desc    : Remove all *~ files recursively from current directory.
cleanbakfiles() {
	local dir=${1-}
	if ((${#dir})); then dir="$(readlink -f "$dir")"
 									else dir=$(pwd) 
	fi
	if [[ -d $dir ]]; then 
		echo "Cleaning ${dir}..."
		find "$dir" -name "*~" 			-type f -exec rm {} \;
		find "$dir" -name "DEADJOE" -type f -exec rm {} \;
	else
		echo >&2 "Directory $dir not found!"
	fi
}

# place code below
# if this file is being included into another shell or script, then declare function for export, and exit
	# script is being run
#	if [[ ${0:-} == ${BASH_SOURCE[0]:-} ]]; then
		# the file has been executed as a script from the command line or from another script
#		cleanbakfiles "$@"
	# source entities has been executed at the shell command prompt
#	else
		# ((${#BASH_SOURCE})) || [[ ${0:-} == '-bash' ]]; then
#		declare -fx cleanbakfiles
#			alias cln='cleanbakfiles'
#	fi
