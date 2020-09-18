#!/bin/bash
#X Function : is.interactive
#X Desc     : return 0 if tty available, otherwise 1.
#X Synopsis : is.interactive [report|noreport*]
#X Example  : is.interactive && ask.yn "Continue?"
#X NOTE     : !!requires attention
is.interactive() {
	declare report=${1:-}
	declare -i isit=0 echoit=0
	# echo results? default is no.
	if [[ -n $report ]]; then
		case "${1:-}" in
			report)		echoit=1;;
			noreport)	echoit=0;;
		esac
	fi
	# look for positives first
	if [[ -t 1 ]]; then 
		isit=1
		((echoit)) && echo "${isit}: STDOUT is attached to TTY."
	fi
	#
	if [[ "${PS1+x}" == 'x' ]]; then
		((echoit)) && echo "${isit}: PS1 is set. This is possibly an interactive shell."
		if (( ${#PS1} > 1 )); then
			isit=1
			((echoit)) && echo "${isit}: PS1 is set and has a length -gt 1. This is very probably an interactive shell."
		fi
	fi
	#	
	if [[ "$-" == *"i"* ]]; then
		isit=1
		((echoit)) && echo "${isit}: \$- = *i*"
	fi
	# look for negatives		
	if [[ -p /dev/stdout ]]; then
		isit=0
		((echoit)) && echo "${isit}: STDOUT is attached to a pipe."
	fi
	# 
	if [[ ! -t 1 && ! -p /dev/stdout ]]; then
		isit=0
		((echoit)) && echo "${isit}: STDOUT is attached to a redirection."
	fi
	# echo the result
	if ((echoit)); then
		((isit)) && echo '1: is interactive' || echo '0: is not interactive'
	fi
	# return true/false
	return $(( ! isit ))
}
declare -fx 'is.interactive'
	alias is_interactive='is.interactive'
#fin
