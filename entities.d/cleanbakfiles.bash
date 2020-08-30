#!/bin/bash

#X Function: cleanbakfiles cln
#X         : this function is also a command line accessable script
#X Desc    : Remove all *~ files recursively from current directory.
#X         : CLNTEMPFILES array defines temporary files, default:( '*~' '~*' '.~*' )
declare -ax CLNTEMPFILES=( '*~' '~*' '.~*' 'DEADJOE' )
cleanbakfiles() {
	local PRG=cleanbakfiles
	usage() {
		echo "Usage: ${PRG:-cleanbakfiles} [--maxdepth|-m depth] [--dryrun|-n || --notdryrun|-N] [--quiet|-q || --verbose|-v] [dir]..."
		echo "Desc : Recursively remove all temporary files ( ${CLNTEMPFILES[@]:- *~ ~* .~*} )"
		echo '     : Defaults: maxdepth 2, verbose enabled, dryrun enabled'
		echo '     : More than one directory can be specified. Default is current directory.'
		echo "     : if defined, CLNTEMPFILES envar sets temporary files to search for. Default is ( '*~' '~*' '.~*' )"
	}
	local -i maxdepth=2 verbose=1 dryrun=1 
	declare -ix filecount=0
	local tmpfc="/tmp/fc-$RANDOM"
	local -a adir
	while (($#)); do
		case $1 in
			-h|--help)			usage; return ;;
			-n|--dryrun)		dryrun=1 ;;
			-N|--notdryrun)	dryrun=0 ;;
			-m|--maxdepth)	shift; maxdepth=${1:- 2} ;;
			-v|--verbose)		verbose=1 ;;
			-q|--quiet)			verbose=0 ;;
			*)							adir+=( "$1" ) ;;
		esac
		shift
	done
	((${#adir[@]})) || adir=( "$(pwd)" ) 
	maxdepth=$((maxdepth)) || return $?
	((maxdepth<1)) && maxdepth=1

	[[ -z "${CLNTEMPFILES[@]}" ]] && CLNTEMPFILES=( '*~' '~*' '.~*' 'DEADJOE' )
	local TempExpr=''
	for r in "${CLNTEMPFILES[@]}"; do
		TempExpr+="$( [[ -z $TempExpr ]] || echo '-o ')-name '$r' -type f "
	done

	((verbose && dryrun)) && echo "$PRG: start DRY RUN"
	echo -n '0' > $tmpfc
	for dir in "${adir[@]}"; do
		dir="$(readlink -f "$dir")"
		if [[ -d "$dir" ]]; then 
			((verbose)) && echo "$PRG: searching directory ${dir} maxdepth $maxdepth"
			eval "/usr/bin/find "$dir" -maxdepth ${maxdepth:- 1} $TempExpr" \
					| while read -r line; do 
							((verbose)) && echo "$PRG:   $( ((dryrun)) && echo 'would remove' || echo 'removing') $line"
							((dryrun)) || rm "$line"
							echo -n $(( $(cat $tmpfc) + 1 )) > $tmpfc
						done
		else
			echo >&2 "$PRG: Directory $dir not found!"
		fi
	done	
	filecount=$(cat $tmpfc); rm $tmpfc
	((verbose)) && echo "$PRG: $filecount file$( ((filecount==1)) || echo 's' ) found"
	((verbose && dryrun)) && echo "$PRG: finish DRY RUN$( ((filecount)) && echo ' (-N to remove files)')"
	return 0
}
declare -fx cleanbakfiles

#fin
