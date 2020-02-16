#!/bin/bash

#X Function: entities.change_location
#X Desc    : change base directory of ENTITIES envvar and add to PATH.
#X Synopsis: entities.change_location [{dir_location}]
entities.change_location() {
	local newlocation="${1:-}" newpath IFS OLDIFS p
	if ((! $# )) || [[ -z $newlocation ]]; then
		newlocation="$ENTITIES"
		if [[ -z $newlocation ]] || [[ ! -f "$newlocation/entities.bash" ]]; then
			newlocation="$(dirname "$(which entities.bash)")"
		fi
	fi
	newlocation="$(readlink -e "$newlocation")"
	[[ -z "$newlocation" ]] && { echo "#?! Invalid entities location ${1:-}"; return 127; }

	[[ ! -f "${newlocation}/entities.bash" ]] && { echo "#?! Warning: No entities.bash script found at [$newlocation]"; return 127; }

	# remove old ENTITIES from PATH
	newpath=":${PATH}:"
	newpath="${newpath//\:${ENTITIES}\:/}"
	newpath="${newpath//\:${newlocation}\:/}"
	# add new path
	newpath="$newpath:${newlocation}"
	# delete :: and leading :
	newpath="${newpath//::/:}";	[[ "${newpath:0:1}" == ':' ]] && newpath="${newpath:1}"

	# make array from newpath and get rid of non-existant directories
	OLDIFS="$IFS"; IFS=$':'; arr=( $newpath );	IFS="$OLDIFS"
	newpath=''
	for p in ${arr[@]}; do [[ -d $p ]] && newpath+="$p:"; done
	[[ "${newpath: -1}" == ':' ]] && newpath="${newpath:0:-1}"	#delete trailing :

	export PATH="$newpath"
	export ENTITIES=${newlocation}
	echo "ENTITIES=\"$ENTITIES\";PATH=\"$PATH\""
	return 0
}
declare -fx entities.change_location

#fin
