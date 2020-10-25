#!/bin/bash
#X Function: titlecase
#X Desc    : Upper case first letter of each word, lowercase the rest.
#X Synopsis: titlecase "str" [...]
#X Example : str="dharmA bUms"
#X         : titlecase "$str"
titlecase() { 
	(( $# )) || { echo ''; return 0; }
	[[ -z $* ]] && { echo ''; return 0; } 
	set ${*,,}
	echo ${*^}
}
declare -fx titlecase
#fin
