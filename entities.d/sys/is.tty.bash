#!/bin/bash
#X Function: is.tty 
#X Desc    : return 0 if tty available, otherwise 1.
#X Synopsis: is.tty
#X Example : is.tty && msg.yn "Continue?"
#X Depends : tty
is.tty() { 
	# [[ -t 0 ]] is this the same??
	tty --quiet	2>/dev/null	|| return $?
	return 0
}
declare -fx 'is.tty'
	is_tty() { 'is.tty'; }; declare -fx 'is_tty'
	
#fin
