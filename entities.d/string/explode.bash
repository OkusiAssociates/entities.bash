#!/bin/bash
#X Function: explode 
#X Desc    : Convert delimited string into array.
#X         : For most cases, this would be better done inline:
#X         :   IFS=',' array=( "${cdstring" )
#X Synopsis: explode "delimiter" "${array[@]}"
#X Example : str=( $(explode '|' "${files[@]}") )
explode() {	
	local IFS
	local -a a
	IFS="$1" a=( "${@:2}" )
	echo "${a[@]}"; 
}
declare -fx explode
#fin
