#!/bin/bash
#X Function: hr2int
#X Desc		: return integer from human-readable number text
#X				 : (b)ytes	(k)ilobytes (m)egabytes (g)igabytes (t)erabytes (p)etabytes
#X					 Capitalise to use multiples of 1000 (S.I.) instead of 1024.
#X Synopsis: hr2int <integer>[bkmgtp] [<integer>[bkmgtp]]...
#X Example : hr2int 34M
#X				 : hr2int 34m
#X				 : hr2int 34000000
declare -Aix HRint=( [b]=1 [k]=1024 [m]=1024000 [g]=1024000000 [t]=1024000000000 [p]=1024000000000000 \
										 [B]=1 [K]=1000 [M]=1000000 [G]=1000000000 [T]=1000000000000 [P]=1000000000000000 )
hr2int() {
	local num='' h=''
	while (($#)); do
		num=${1:-0} 
 		h=${num: -1}
		if [[ 'bBkKmMgGtTpP' == *"$h"* ]]; then
			echo $(( ${HRint[$h]} * ${num:0:-1})) || return 1
		else
			echo $(( num )) || return 1
		fi
		shift 1
	done
	return 0
}

#X function: int2hr 
#X synopsis: int2hr <integer> <hr> [<integer> <hr>]...
#X				 : <number> is any integer
#X				 : <hr> is one of {b|B|k|K|m|M|g|G|t|T|p|P}
#X Example : int2hr 34393827 m
#X Example : int2hr 10382 K 872929292929 g
int2hr() {
	local -i num=0
	local h=''
	while (($#)); do
		num=$(( ${1:-0} )) || return 1 
 		h=${2:-b}
		if [[ 'bBkKmMgGtTpP' == *"$h"* ]]; then
			echo "$((num / ${HRint[$h]}))${h}" || return 1
		else
			echo >&2 "Invalid hr code [$h]"; return 1
		fi
		shift 1
		(($#)) && shift 1
	done
	return 0	
}

#hrsize2int "$@"
#fin

 