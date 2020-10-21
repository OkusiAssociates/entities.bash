#!/bin/bash
#X Function: website_online 
#X Desc    : Return true if website is available and online.
#X Synopsis: website_online "website"...
#X Example : website_online 'okusi.id' 'okusiassociates.com' && echo 'Online'
website_online() {
	while(($#)); do
		( curl --head --insecure "$1" 2>/dev/null | grep -w "200\|301" >/dev/null) ||	return 1
		shift
	done
	return 0	
}
declare -fx 'website_online'
#fin
