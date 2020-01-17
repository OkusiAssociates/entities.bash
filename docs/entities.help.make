#!/bin/bash

ENTITIES=$OKROOT/entities
export ENTITIES

source $ENTITIES/entities.bash new || { echo >&2 "Could not open entities.bash!"; exit 1; }
	strict.set off
	trap.set on

	declare -a hdrs=(Intro Global Local Function File)
	declare -a subhdrs=(Synopsis Desc Defaults Depends Example See_Also Tags)
	declare -a Symlinks=()
	declare Label='' Header='' Synopsis='' Desc='' Defaults='' \
					Depends='' Example='' See_Also='' Tags=''
	declare DestDir="$ENTITIES/docs/help"
	declare -i auto=0 wipe=0

	declare dashes='----------------------------------------------------------------------------'
	
main() {
	exit_if_not_root
#	exit_if_already_running
	declare label='Intro' oldlabel='' lbl='' cmt=''
	local IFS=$'\n'

	cmd=()
	while (($#)); do
		case "$1" in
			-y|--auto)			auto=1; wipe=1;;
			-h|--help)			usage exit;;
			-v|--verbose)		verbose.set on;;
			-q|--quiet)			verbose.set off=;;
			*)							cmd+=( "$1" );;
		esac
		shift
	done

	if ((auto)); then
		verbose.set off
		color.set off
	fi

	msg "$PRG"
	tab.set ++
	msginfo "Create help pages from canonical entities.bash file to " "directory $DestDir." 

	if ((!auto)); then
		echo ''
		askyn "Do you wish to proceed?" || exit 1
	fi

	if ((!auto)); then
		echo ''
		askyn "Wipe the [$DestDir] directory?" && wipe=1
	fi
	if ((wipe)); then
		echo ''
		msginfo "Deleting all files in [$DestDir]..."
		rm -rf "$DestDir/"
		mkdir -p "$DestDir"
	fi

bashfiles="$(find $ENTITIES/ -name "*.bash" -type f | grep -v 'docs/' | grep -v '.gudang' | grep -v '.min.')"
for file in ${bashfiles[@]}; do
	msginfo "" "Processing $file for documentation"
	hlp="$(grep '^#X\+' "$file" | grep ':')"
	for l in ${hlp[@]}; do 
		lbl=$(str_str "$l" '#X' ':')
		lbl=$(trim "$lbl")
		lbl=${lbl/ /_}
		cmt="${l#*: }"
		cmt=$(rtrim "$cmt")
		[[ -z "$cmt" ]] && continue
		if [[ -z "$lbl" ]]; then
			v="${label}+=\${cmt}\"\${LF}\""
			eval "$v"
			continue
		fi

		label=$lbl # there's a new label in town
		if [[ "${hdrs[@]}" == *"$label"* ]]; then  # check if new label is a header category
			#msginfo "header [$label] found"
			if (( ${#Label} )); then
				destdir="$DestDir/$Label"
				mkdir -p "$destdir"

				declare -a Symlink=()
				IFS=$' \t';	Symlink=( $Header ); IFS=$'\n'
				#msginfo "#write $label out to file $Label:$destdir"
				endtag="$Label-"
				sx=$((10 - ${#endtag} ))
				endtag+="-${Symlink[0]}"
				endtag=$(printf "#%${sx}.${sx}s%s" $dashes $endtag)
				(	echo "${endtag}"
					printlines "$Label"  "$Header"
					printlines 'Tags' "$Tags"
					printlines 'Desc' "$Desc"
					printlines 'Synopsis' "$Synopsis"
					printlines 'Defaults' "$Defaults"
					printlines 'Depends' "$Depends"
					printlines 'See_Also' "$See_Also"
					printlines 'Example' "$Example"
					sx=$(( 76-${#endtag} ))
					printf "%s--%${sx}.${sx}s%s" "$endtag" "$dashes" "$LF"
				) > "$destdir/${Symlink[0]}"

				IFS=$' \t\n'
				for s in ${Symlink[@]:1}; do
					cd "$destdir"
					ln -fs "${Symlink[0]}" "${s}"
					cd - >/dev/null
				done
				IFS=$'\n'
			fi
			Label="$label"
			Header="$cmt"
			Synopsis='' Desc='' Defaults='' Depends='' Example='' See_Also='' Tags=''

		elif [[ "${subhdrs[@]}" == *"$label"* ]]; then  # check if new label is a subheader category
			#msginfo "  subheader [$label] found"
			v="${label}+=\${cmt}\"\${LF}\""
			eval "$v"
		else
			msgerr "Bad label [$label]; not found in headers or subheaders."
		fi

		oldlabel=$label
	done
done


	# make symlinks in the help root to canonical files in category directories
	msginfo "" "Making symlinks in the help root ($DestDir)" "to canonical files in category directories."
	cd "$DestDir" || msgdie "Could not cd into [$DestDir]"
	for c in $(find -L . -mindepth 1 -type f); do 
		target="${c:2}"
		ln -fs "$target" "$(basename $target)" >/dev/null
	done 

	tab.set 0
	msg "$PRG is complete." ""
}

	
cleanup() {
	[[ $1 == '' ]] && exitcode=$? || exitcode=$1
	exit $exitcode
}

usage() {
	cat <<-usage
		Usage: $PRG [[-v|--verbose] [-q|--quiet]] [-h|--help]

	usage
	[[ $1 == 'exit' ]] && exit 1
}

printlines() {
	local label="$1" content="$2"
 	local IFS=$'\n'	
	content=$(trim "$content")
	[[ -z "$content" ]] && return 0
	for l in $content; do
		printf '%10.10s: %s\n' "$label" "$l"
		label=''
	done
}

main "$@"
#fin
