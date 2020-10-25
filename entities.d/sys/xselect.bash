#!/bin/bash
#X Function: xselect
#X Desc		 : [select] command alternative.
#X         : Returns name of item selected, or exit key preceeded with '!'.
#X Synopsis: xselect [-p "prompt"] [-i num] [-w num] [-c num] array
#X         :   array               An array of any kind.
#X         :   -p|--prompt str     Select prompt. Default 'Select: '
#X         :   -i|--itempad num    Number of spaces at the end of select item.
#X         :   -w|--itemwidth num  Max width of each select item. 
#X         :   -c|--columns num    Number of screen columns (Default COLUMNS) 
#X         :
#X Examples: filename=$(xselect *)
#X         : [[ $filename == '!0' ]] && return
#X         : [[ $filename == '!q' ]] && exit
#X         : $EDITOR "$filename"
xselect() {
	local pathname reply prompt='Select: '
	local -i COLUMNS
	COLUMNS=$(tput cols 2>/dev/null || echo '78')
	local -i i stcol numcols
	local -i columnwidth itemwidth=10 itempad=2 numpad=0
	local -a Items=() ItemsDisp=()
	i=0
	while(($#)); do
	#for pathname in "$@"; do
		case $1 in
			-p|--prompt)		shift; (($#)) && prompt="$1";;
			-i|--itempad)		shift; (($#)) && itempad=$1;;
			-w|--itemwidth)	shift; (($#)) && itemwidth=$1;;
			-c|--columns)		shift; (($#)) && COLUMNS=$1;;
			*)	pathname="$1"
					Items+=( "$pathname" )
					pathname=$(basename "$pathname")
					(( ${#pathname} > itemwidth )) && itemwidth=${#pathname}
					ItemsDisp+=( "$pathname" )
					i+=1;;
		esac
		shift
	done
	
	numpad=${#i}
	columnwidth=$((numpad + 2 + itemwidth + itempad))
	numcols=$((COLUMNS / columnwidth))

	while((1)); do
		stcol=0; i=0
		for pathname in "${ItemsDisp[@]}"; do
			i+=1
			printf "%${numpad}.${numpad}d) %-${itemwidth}.${itemwidth}s%-${itempad}.${itempad}s" "$i" "$(basename "$pathname")" '           ' >&2
			stcol+=1; ((stcol >= numcols)) && { stcol=0; echo >&2; } 
		done
		((stcol)) && echo	>&2

		read -r -p "$prompt" reply >&2
		[[ -z $reply ]] && continue
		[[ $reply == '0' || $reply == 'q' ]] && { echo "!$reply"; return 0; }		
		# is.int
    [[ ${reply:-} =~ ^[-+]?[0-9]+$ ]] || continue
		i=${reply%%)*}	
		if (( i > "${#Items[@]}" || i < 1 )); then
			echo 'Invalid selection.' >&2
		else
			echo "${Items[$i-1]}"
			return 0
		fi
	done
}
declare -fx 'xselect'
#fin
