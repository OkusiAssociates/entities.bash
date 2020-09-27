#!/bin/bash
#X Function: hr2int
#X Desc		 : return integer from human-readable number text
#X				 : (b)ytes	(k)ilobytes (m)egabytes (g)igabytes (t)erabytes (p)etabytes
#X				 : Capitalise to use multiples of 1000 (S.I.) instead of 1024.
#X Synopsis: hr2int integer[bkmgtp] [integer[bkmgtp]]...
#X Example : hr2int 34M
#X				 : hr2int 34m
#X				 : hr2int 34000000
declare -Aixg _ent_HRint=( [b]=1 [k]=1024 [m]=1024000 [g]=1024000000 [t]=1024000000000 [p]=1024000000000000 \
										 [B]=1 [K]=1000 [M]=1000000 [G]=1000000000 [T]=1000000000000 [P]=1000000000000000 )
hr2int() {
	local num='' h='' fmt=si
	while (($#)); do
		num=${1:-0} 
 		h=${num: -1}
		if [[ ${h:-} =~ ^[-+]?[0-9.]+$ ]]; then 
			fmt=si
		else
			local LC_ALL=C
			if [[ "$h" > 'a' ]]; then 
				fmt=iec
			else 
				fmt=si		
			fi
		fi
		numfmt --from="$fmt" "${num^^}" || return 1
		shift 1
	done
	return 0
}
declare -fx hr2int

#X Function: int2hr 
#X Desc    : Convert integer to human-readable string, using SI (base 1000)
#X         : or IEC (1024) for conversion.
#X Synopsis: int2hr number [si|iec] [number [si|iec]]...
#X				 :   number   is any integer.
#X				 :   si|iec   number format (si: 1k=1000, iec: 1K=1024)
#X         :            Default format is 'si'.
#X Example : int2hr 1000 si 1000 iec 1024 si 1024 iec
#X         : int2hr 10382 iec 872929292929 si
int2hr() {
	local -i num 
	local fmt hr
	while (($#)); do
		num=$(( ${1:-0} )) || { echo >&2 "Invalid number [$num]"; return 1; }
 		fmt=${2:-si}
		fmt=${fmt,,}
		hr=$(numfmt --to="$fmt" "$num") || { echo >&2 "Invalid hr code [$h]"; return 1; }
		[[ $fmt == 'iec' ]] && hr="${hr,,}"
		echo "$hr"
		shift 1
		(($#)) && shift 1
	done
	return 0	
}
declare -fx int2hr
#fin
