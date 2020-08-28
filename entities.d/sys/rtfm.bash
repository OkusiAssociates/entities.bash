#X Function: rtfm
#X Usage: rtfm <search_term>
rtfm() { help $@ || man $@ || ${BROWSER:-$(which w3m || which lynx)} "http://www.google.com/search?q=$@" || return 0; }

