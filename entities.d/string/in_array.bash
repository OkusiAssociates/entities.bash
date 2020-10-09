#!/bin/bash
#X Function: in_array
#X Desc    : Return true is exact match for string is found in string list.
#X Synopsis: in_array "needle" "haystack[*]"
#X Example : in_array 'okusi2' 'okusi1 okusi2 okusi3' && echo 'found'
in_array() { 
	local t; 
	for t in ${2:-}; do [[ $t == "$1" ]] && return 0; done
	return 1 
}
declare -fx 'in_array'
#fin


