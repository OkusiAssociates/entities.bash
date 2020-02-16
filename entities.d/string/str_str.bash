#!/bin/bash
#X Function : str_str
#X Desc     : return string that occurs between two strings
#X Synopsis : str_str string beginstr endstr 
#X Example  : param=$(str_str "this is a [[test]]] of str_str" '[[' ']]'
str_str() {
	local str
	str="${1#*${2}}"
 	str="${str%%${3}*}"
 	echo -n "$str"
}
declare -fx str_str

#fin
