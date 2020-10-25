#!/bin/bash
# #! shellcheck disable=SC
#X Function: sqslash
#X Desc    : Add backslash to every single quote char (').
#X         : If specified, takes parameter argument first.
#X         : if no parameters specifed, assume input from stdin. 
#X Synopsis: sqslash [string] 
#X Example : sqslash "Hello 'World'!
#X         : echo "Hello 'World'! | sqslash
#X         : sqslash <myfile.txt
sqslash() {
	if (($#)); then
		echo "${@//\'/\\\'}"
	else
		while read -r l; do echo "${l//\'/\\\'}"; done
	fi
}
declare -fx sqslash

#X Function: dqslash
#X Desc    : Add backslash to every double quote char (").
#X         : If specified, takes parameter argument first.
#X         : if no parameters specifed, assume input from stdin. 
#X Synopsis: dqslash [string] 
#X Example : dqslash 'Hello "World"!'
#X         : echo 'Hello "World"!' | dqslash
#X         : dqslash <myfile.txt
dqslash() {
	if (($#)); then
		echo "${@//\"/\\\"}"
	else
		while read -r l; do echo "${l//\"/\\\"}"; done
	fi
}
declare -fx dqslash

#fin
