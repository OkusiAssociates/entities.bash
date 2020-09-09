#!/bin/bash
#X Function: clntempfiles 
#X Desc    : Remove all *~ files recursively from current directory.
#X         : CLNTEMPFILES array defines temporary files, default is ( '*~' '~*' '.~*' )
#X Usage   : clntempfiles [--maxdepth|-m depth] [--dryrun|-n || --notdryrun|-N] 
#X         :     [--quiet|-q || --verbose|-v] [dirspec]...
#X Desc    : Recursively remove all temporary files ( ${CLNTEMPFILES[@]} )"
#X         : Defaults: maxdepth 2, verbose enabled, dryrun enabled'
#X         : More than one dirspec can be specified. Default is current directory.'
#X         : If defined, CLNTEMPFILES envar sets temporary files to search for. 
#X         : Default is ( '*~' '~*' '.~*' )"
declare -ax CLNTEMPFILES=( '*~' '~*' '.~*' 'DEADJOE' 'dead.letter' )
clntempfiles() {
	(( ${#CLNTEMPFILES[@]} )) || CLNTEMPFILES=( '*~' '~*' '.~*' 'DEADJOE' 'dead.letter' )
	local PRG=cln
	usage() {
		echo "Usage: ${PRG} [--maxdepth|-m depth] [--dryrun|-n||--notdryrun|-N] [--quiet|-q||--verbose|-v] [dirspec]..."
		echo "Desc : Recursively remove all temporary files defined in CLNTEMPFILES[] ( ${CLNTEMPFILES[@]} )"
		echo '     : Defaults: maxdepth 2, verbose enabled, dryrun enabled'
		echo '     : More than one dirspec can be specified. Default is current directory.'
		echo "     : Envvar CLNTEMPFILES[] defines temporary files, default is ( '*~' '~*' '.~*' )"
		echo "     : If not defined, CLNTEMPFILES[] defaults to ( '*~' '~*' '.~*' )"
	}
	local -i maxdepth=2 verbose=1 dryrun=1 filecount=0
	# tmpfc: file-filecounter, try and open in /run if possible, otherwise much slower /tmp.
	local tmpfc="$( [[ -w /run ]] && echo '/run' || echo '/tmp' )/${PRG}-${RANDOM}"
	local -a aDir
	while (($#)); do
		case $1 in
			-h|--help)			usage; return ;;
			-n|--dryrun)		dryrun=1 ;;
			-N|--notdryrun)	dryrun=0 ;;
			-m|--maxdepth)	shift; maxdepth=${1:- 2} ;;
			-v|--verbose)		verbose=1 ;;
			-q|--quiet)			verbose=0 ;;
			*)							aDir+=( "$1" ) ;;
		esac
		shift
	done
	((${#aDir[@]})) || aDir=( $(readlink -f "$(pwd)") )
	maxdepth=$((maxdepth)) || return $?
	((maxdepth < 1)) && maxdepth=1

	local TempExpr=''
	for r in "${CLNTEMPFILES[@]}"; do
		TempExpr+="$( [[ -z $TempExpr ]] || echo '-o ')-name '$r' -type f "
	done

	local dir
	echo -n '0' > $tmpfc # zero file-filecounter
	for dir in "${aDir[@]}"; do
		dir="$(/bin/readlink -f "$dir")"
		if [[ -d "$dir" ]]; then 
			((verbose)) && echo "$PRG: Searching directory [${dir}], maxdepth=$maxdepth"
			eval "/usr/bin/find "$dir" -maxdepth ${maxdepth:- 1} $TempExpr" \
					| while read -r line; do 
							((verbose)) && echo "$PRG:   $( ((dryrun)) && echo '- would remove' || echo '- removing') $line"
							((dryrun)) || rm "$line"
							(( $? )) || echo -n $(( $(cat $tmpfc) + 1 )) > $tmpfc; # increment file-filecounter
						done
		else
			echo >&2 "$PRG: Directory [${dir}] not found!"
		fi
	done
	filecount=$(cat $tmpfc); rm $tmpfc # file-filecounter no longer needed
	if ((verbose)); then
		if ((filecount)); then
			echo "$PRG: $filecount file$( ((filecount==1)) || echo 's' ) $( ((dryrun)) && echo 'would be ')deleted"
		else
			echo "$PRG: No temporary files found."
		fi
	fi

	if ((verbose && dryrun && filecount > 0)) && [ -t 0 ]; then
		read -t 0.2 -n 1024 # clear typeahead buffer
		read -n1 -p "$PRG: Delete all these files? (y/N) " line
		echo ''
		if [[ ${line,,} == 'y' ]]; then
			clntempfiles  --notdryrun --maxdepth ${maxdepth} $( ((verbose)) && echo '--verbose' || echo '--quiet' ) "${aDir[@]}"
			return $?
		fi
	fi
	
	return 0
}
declare -fx clntempfiles

#fin
