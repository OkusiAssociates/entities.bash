#!/bin/bash
#X Function : trim ltrim rtrim
#X Desc     :   trim   strip string of leading and trailing space chars
#X          :   ltrim  strip string of leading space chars
#X          :   rtrim  strip string of trailing space chars
#X Synopsis : trim string
#X Example  : str=" 123 "; str=$(trim "$str")
trim()  { 
	local v="$*"
	v="${v#"${v%%[![:space:]]*}"}"
	v="${v%"${v##*[![:space:]]}"}"
	echo -n "$v"
}
ltrim() {
	local v="$*"
	v="${v#"${v%%[![:space:]]*}"}"
	echo -n "$v"
}
rtrim() {
	local v="$*"
	v="${v%"${v##*[![:space:]]}"}"
	echo -n "$v"
}
declare -fx trim rtrim ltrim
#fin
