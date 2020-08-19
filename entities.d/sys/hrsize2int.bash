#!/bin/bash
#X Function: hrsize2int
#X Desc    : return integer from human-readable number text
#X Synopsis: hrsize2int number[bkmgtp]
#X Example : hrsize2int 34M
#X         : hrsize2int 34m
#X         : hrsize2int 34000000
hrsize2int() {
	# (b)ytes  (k)ilobytes (m)egabytes (g)igabytes (t)erabytes (p)etabytes
	# Capitalise to use multiples of 1000 (S.I.) instead of 1024.
  declare -Ai Hh=( [b]=1 [k]=1024 [m]=1024000 [g]=1024000000 [t]=1024000000000 [p]=1024000000000000 \
 									 [B]=1 [K]=1000 [M]=1000000 [G]=1000000000 [T]=1000000000000 [P]=1000000000000000 )
	declare num=${1:-0} 
 	declare h=${num: -1}
	if [[ 'bBkKmMgGtTpP' == *"$h"* ]]; then
		echo $(( ${Hh[$h]} * ${num:0:-1})) || return 1
	else
		echo $(( num )) || return 1
	fi
	return 0
}

#hrsize2int "$@"
#fin
  
 