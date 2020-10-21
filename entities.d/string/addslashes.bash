#!/bin/bash
#! shellcheck disable=SC2162
#X Function: addslashes
#X Desc    : Insert \ backslash before every single and double quote char. 
#X Synopsis: addslashes
#X Example : cat text1 | addslashes > text2
addslashes() {
	read line; 
	while [[ "$line" != "" ]]; do 
		echo "$line" | sed "s/'/\\\\'/g; s/\"/\\\\\"/g;"
		read line
	done
	return 0
}
declare -fx addslashes
#fin
