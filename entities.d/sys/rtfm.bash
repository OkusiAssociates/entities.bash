#!/bin/bash
#X Function: rtfm
#X Desc    : Read The Fucking Manual. 
#X         : Searches for command first in [help], then [man], 
#X         : then [entities.help], then [google search] using $BROWSER.
#X         : If BROWSER not defined, defaults to w3m or lynx.
#X         : For convenience in a terminal, set alias man='rtfm'
#X Synopsis: rtfm ["command"]
#X Depends : man entities.help w3m lynx
rtfm() { 
	if [[ -z ${1:-} || ${1:-} == '-h' || ${1:-} == '--help' ]]; then
		echo 'Script  : rtfm'
		echo 'Desc    : read-the-fucking-manual wrapper for help -> man -> entities.help -> google'
		echo 'Synopsis: rtfm "command"'
		return 1
	fi

	builtin help -m "$@" 2>/dev/null && return 0
	
	$(which man) 		"$@" 2>/dev/null && return 0

	entities.help 	"$@" 2>/dev/null && return 0 

	"${BROWSER:-$(which w3m || which lynx)}" "http://www.google.com/search?q=linux+bash+%2B$*" \
			&& return 0
}
declare -fx rtfm
#fin
