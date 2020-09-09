#!/bin/bash
#X Function: is.number 
#X Desc    : Is parameter a number? return true/false
#X Synopsis: is.number "numstr"
#X Example : is.number "$1" && echo "$1 is number"
is.number() {
	[[ ${1:-} =~ ^[-+]?[0-9]+$ ]] && return 0 || return 1
}
declare -fx is.number
#fin
