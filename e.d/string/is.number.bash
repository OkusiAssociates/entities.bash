#!/bin/bash
#X Function: is.number 
#X Desc    : Is parameter a number? Return true/false
#X Synopsis: is.number "numstr"
#X Example : is.number "420"  && echo "$1 is number"  # returns true
#X         : is.number "4.20" && echo "$1 is number"  # returns true
#X         : is.number "4Z20" && echo "$1 is number"  # returns false
is.number() {	[[ ${1:-} =~ ^[-+]?[0-9.]+$ ]] || return 1; }
declare -fx 'is.number'

#X Function: is.int
#X Desc    : Is parameter an integer? Return true/false
#X Synopsis: is.int "numstr"
#X Example : is.int "420"  && echo "is int"  # returns true 
#X         : is.int "4.20" && echo "is int"  # returns false 
#X         : is.int "4Z20" && echo "is int"  # returns false
is.int() {	[[ ${1:-} =~ ^[-+]?[0-9]+$ ]] || return 1; }
declare -fx 'is.int'
#fin
