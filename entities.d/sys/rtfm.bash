#X Function: rtfm
#X Desc: read the fucking manual, searches command in help, man, then google.
#X Usage: rtfm <search_term>
rtfm() { 
	if [[ -z ${1:-} ]]; then
		echo "read the fucking manual, searches command in help, man, then google."
		return 1
	fi

	help "$@" 2>/dev/null && return 0
	
	man "$@"  2>/dev/null && return 0

	${BROWSER:-$(which w3m || which lynx)} "http://www.google.com/search?q=linux+bash+$@" && return 0
}
#fin
