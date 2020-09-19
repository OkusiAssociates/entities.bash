#!/bin/bash
#X Function: implode 
#X Desc    : Convert array[@] into delimited string.
#X Synopsis: implode [-d "delimiter"] "${array[@]}"
#X         : -d if specified must preceed array.
#X Example : str=$(implode -d '|' "${files[@]}")
implode() {
	local x d=','
	[[ ${1:-} == '-d' ]] && { shift; d="${1:-,}"; shift; }
	printf -v x "${d}%s" "$@"
	echo "${x:1}"
}
#fin
