#X Function: rtfm
#X Desc    : read the fucking manual. 
#X         : Searches first in help, then man, then google using $BROWSER.
#X         : If BROWSER not defined, defaults to w3m or lynx.
#X Synopsis: rtfm "search_term"
rtfm() { 
	if [[ -z ${1:-} || ${1:-} == '-h' || ${1:-} == '--help' ]]; then
		echo "rtfm - read the fucking manual"
		echo "Searches command in help, man, then tries to google it."
		return 1
	fi

	help -m "$@" 2>/dev/null && return 0
	
	man "$@"  2>/dev/null && return 0

	${BROWSER:-$(which w3m || which lynx)} "http://www.google.com/search?q=linux+bash+$@" && return 0
}
declare -fx rtfm
#fin
