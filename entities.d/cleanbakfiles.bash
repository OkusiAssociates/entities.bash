#!/bin/bash

#X Function: cleanbakfiles cln
#X         : this function is also a command line accessabe script
#X Desc    : Remove all *~ files recursively from current directory.
cleanbakfiles() {
	local PRG=cleanbakfiles
	usage() {
		echo "Usage: ${PRG:-cleanbackfiles} [--maxdepth|-m depth] [--dryrun|-n] [--quiet|-q || --verbose|-v] [dir]..."
		echo "Desc: Remove all temporary files: .~*|~*|.*~|*~|.#*|DEADJOE"
		echo '    : Defaults: maxdepth 5, verbose enabled, dryrun enabled, dir $PWD'
		echo '    : More than one dir can be specified.'
	}
	local -i maxdepth=5 verbose=1 dryrun=1
	local -a adir
	while (($#)); do
		case $1 in
			-h|--help)			usage; return ;;
			-n|--dryrun)		dryrun=1 ;;
			-N|--notdryrun)	dryrun=0 ;;
			-m|--maxdepth)	shift; maxdepth=${1:- 1} ;;
			-v|--verbose)		verbose=1 ;;
			-q|--quiet)			verbose=0 ;;
			*)							adir+=( "$1" ) ;;
		esac
		shift
	done
	((${#adir[@]})) || adir=( "$(pwd)" ) 

	((verbose)) && echo "$PRG start $( ((dryrun)) && echo 'DRY RUN')"
	for dir in "${adir[@]}"; do
		dir="$(readlink -f "$dir")"
		if [[ -d "$dir" ]]; then 
			((verbose)) && echo "$PRG ${dir}..."
			/usr/bin/find "$dir" -maxdepth ${maxdepth:- 1} -type f \
				| egrep '(.*~|*~|DEADJOE)' \
					| while read -r line; do 
							((verbose)) && echo "  rm $line"
							((dryrun)) || rm "$line"
						done
		else
			echo >&2 "Directory $dir not found!"
		fi
	done	
	((verbose)) && echo "$PRG finish $( ((dryrun)) && echo 'DRY RUN')"
	return 0
}
declare -fx cleanbakfiles

#fin
