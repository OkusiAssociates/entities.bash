#!/bin/bash
#X Function: pause
#X Synopsis: pause [-t timeout] [message_str]...
#X Desc    : Print message_str, or '*Pause*' if no message specified,
#X         : wait for one keypress, or until timeout (default 86400).
pause() { 
	local timeout=86400
	if [[ "${1:-}" == '-t' ]]; then
		shift
		timeout=${1:-0}
		shift
	fi
	echo
	read -t "$timeout" -n1 -p "${*:- *Pause*} "
	echo
}
declare -fx pause
#fin
