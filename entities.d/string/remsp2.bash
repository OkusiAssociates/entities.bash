#!/bin/bash
#X Function: remsp2
#X Desc    : Remove double blanks (space,tab) from string, replace with 
#X         : single space, and remove leading and trailing blanks, 
#X Usage   : remsp "string"
#X Example : str=" 123     456 789     0123   "
#X         : str2=$(remsp "$str") 
#X Depends : trim
remsp2() { 
	(($#)) || { echo -n ''; return 0; }
	echo -n "$(trim "${1//+([[:blank:]])/ }")"
}
declare -nx remsp2
#fin

