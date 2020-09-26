#!/bin/bash
#X Function: is.number 
#X Desc    : Is parameter a number? Return true/false
#X Synopsis: is.number "numstr"
#X Example : is.number "420" && echo "$1 is number"
is.number() {	[[ ${1:-} =~ ^[-+]?[0-9.]+$ ]] || return 1; }
declare -fx 'is.number'

#X Function: is.int
#X Desc    : Is parameter an integer? Return true/false
#X Synopsis: is.int "numstr"
#X Example : is.int "4.20" && echo "is number"
is.int() {	[[ ${1:-} =~ ^[-+]?[0-9]+$ ]] || return 1; }
declare -fx 'is.int'

#fin
