#!/bin/bash
#X Function: is.root
#X Desc    : Return error if not root user. Uses whoami and EUID.
#X Synopsis: is.root
#X Depends : whoami
#X Example : is.root || exit 1
is.root() {
	[[ "$(whoami)" == 'root' || $EUID == 0 ]] && return 0
	return 1
}
declare -fx 'is.root'
#fin
