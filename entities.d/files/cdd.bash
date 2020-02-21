#!/bin/bash
#source entities.bash || { echo >&2 "Could not open entities.bash!"; exit 1; }
#	strict.set on
#	verbose.set on

cdd() {
	(( $# )) || return 0

	local dirspec="${1}" pwd=''
	
	if [[ -d $dirspec ]]; then
		cd "$dirspec"; pwd="$(pwd)"

	elif [[ -d "../../../$dirspec" ]]; then
		cd "../../../$dirspec"; pwd="$(pwd)"

	elif [[ -d "../../$dirspec" ]]; then
		cd "../../$dirspec"; pwd="$(pwd)"

	elif [[ -d "../$dirspec" ]]; then
		cd "../$dirspec"; pwd="$(pwd)"

	elif [[ -d "/$dirspec" ]]; then
		cd "/$dirspec"; pwd="$(pwd)"

	else
		msg "Searching PATH"
		local -a apath=( "${PATH//:/$'\n'}" )
		local path='' base=''
		for path in ${apath[@]}; do
			base="$(basename "$path")"
			if [[ $base == $dirspec ]]; then
				if [[ -d "$path" ]]; then
					cd "$path"; pwd="$(pwd)"
					break
				fi
			fi
		done	
		if [[ $pwd == '' ]]; then
			msg "Finding"
			declare -a find=( $( find ../.. -name "${dirspec}*" -type d ) )
			(( ${#find[@]} == 0 )) && find=( $( find ../../.. -name "${dirspec}*" -type d ) )
			if (( ${#find[@]} == 1)); then
					cd "${find[0]}"
					pwd="$(pwd)"
			else 	
				select d in ${find[@]}; do
					cd "$d"
					pwd="$(pwd)"
				done
				((${#pwd})) || msg.err "$dirspec not found"
			fi
		fi
	fi
	[[ $pwd ]] && msg "$pwd"
}

#cdd "$@"
#fin
