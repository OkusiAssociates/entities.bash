#!/bin/bash
#X Function: remsp2
#X Desc    : Remove double space from string, replace with 
#X         : single space, and remove leading and trailing blanks, 
#X Usage   : remsp [-b] "string"
#X         :   -b  include tab characters as space.
#X Example : str=" 123     456 789     0123   "
#X         : str2=$(remsp2 "$str") 
#X         : echo "$str" | remsp2
#X Depends : trim
remsp2() { 
	local -i incblank=0
	if (($#)); then
		if [[ $1 == '-b' ]]; then
			incblank=1
			shift
		fi
	fi
	if (($#)); then 
		if ((incblank)); then
			trim "${1//+( )/ }"; echo
		else
			trim "${1//+([[:blank:]])/ }"; echo
		fi
		return $?
	fi
	local l
	if ((incblank)); then
		while read -r l; do trim "${l//+([[:blank:]])/ }"; echo; done
	else
		while read -r l; do trim "${l//+( )/ }"; echo; done
	fi
	return $?
}
declare -fx remsp2
#fin
