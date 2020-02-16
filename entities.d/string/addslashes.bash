#!/bin/bash
#X Function: addslashes
#X Synopsis: program | addslashes
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
