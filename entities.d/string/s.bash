#X Function: s
#X Desc: print 's' if {numarg} not 1
#X Synopsis: s {numarg}
s() {	(( ${1} == 1 )) || echo -n 's'; }
declare -fx s

