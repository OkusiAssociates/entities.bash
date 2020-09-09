#!/bin/bash
source $(dirname "$0")/entities.bash new || { echo >&2 "Could not open [$(dirname "$0")/entities.bash]."; exit 1; }
	strict.set off
	trap.set on
	
#	ENTITIES=$PRGDIR/entities
#	export ENTITIES
	declare EntitiesDir="$PRGDIR"
	# sanity check
	[[ "$(basename "$EntitiesDir")" == 'entities' ]] || msg.die "Sanity check fail."
	
	declare HelpFilesDir="${PRGDIR}/docs/help"

#     NAME
#     DESCRIPTION
#     SYNOPSIS
#     OPTIONS
#     _other_
#     ENVIRONMENT
#     FILES
#     EXAMPLES
#     AUTHOR
#     REPORTING BUGS
#     COPYRIGHT
#     SEE ALSO
# NAME

	# Category Labels
	declare -a CatHdrs=( 
			Intro 
			Global 
			Local 
			Function 
			File 
			)
	# Subheader Labels
	declare -a SubHdrs=(
			Desc 
			Synopsis 
			Options
			Defaults 
			Env
			Files
			Depends 
			Example 
			Author
			Bugs
			Copyright	
			See_also 
			Tags
			)
			
	# label output			
	declare Label='' 		\
					Header='' 	\
					Synopsis='' \
					Desc='' 		\
					Defaults='' \
					Depends='' 	\
					Example=''  \
					See_also='' \
					Tags=''

	declare -a Symlinks=()

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
			-h|--help)			usage;;
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

	msg "$PRG for entities.bash"
	tab.set ++
	msg "Create help pages from canonical entities.bash file to " "directory $HelpFilesDir." 
	if ((!auto)); then
		askyn "Do you wish to proceed?" || exit 1
	fi
	if ((!auto)); then
		askyn "Wipe the [$HelpFilesDir] directory?" && wipe=1
	fi
	if ((wipe)); then
		msg.info "Deleting all files in [$HelpFilesDir]..."
		rm -rf "$HelpFilesDir/"
		mkdir -p "$HelpFilesDir"
	fi

	bashfiles="$(find "$EntitiesDir/" -name "*.bash"  -not -name "_*" -type f \
								| grep -v '/docs/' | grep -v '.gudang' | grep -v '.min.')"
	#bashfiles="$(find $EntitiesDir/ -name "*.bash" -type f | grep -v 'docs/' | grep -v '.gudang' | grep -v '.min.')"
	for file in ${bashfiles[@]}; do
		msg.info "Processing [$file] for documentation"
		hlp="$(grep '^#X\+' "$file" | grep ':')"
		for hline in ${hlp[@]}; do 
			lbl=$(str_str "$hline" '#X' ':')
			lbl=$(trim "$lbl")
			lbl=${lbl/ /_}
			lbl=${lbl^} # normalise to Title case
			[[ $lbl == 'Usage' || $lbl == 'Useage' ]] && lbl='Synopsis'
			[[ $lbl == 'Examples' || $lbl == 'Eg' ]] && lbl='Example'
			[[ $lbl == 'Requires' || $lbl == 'Dependencies' ]] && lbl='Depends'
			
			cmt="${hline#*: }"
			cmt=$(rtrim "$cmt")
			[[ -z "$cmt" ]] && continue
			if [[ -z "$lbl" ]]; then
				v="${label}+=\${cmt}\"\${LF}\""
				eval "$v"
				continue
			fi
	
			label=$lbl # there's a new label in town
			if [[ "${CatHdrs[@]}" == *"$label"* ]]; then  # check if new label is a header category
				#msg.info "header [$label] found"
				if (( ${#Label} )); then
					destdir="$HelpFilesDir/$Label"
					mkdir -p "$destdir"
	
					declare -a Symlink=()
					IFS=$' \t';	Symlink=( $Header ); IFS=$'\n'
					#msg.info "#write $label out to file $Label:$destdir"
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
						printlines 'See_also' "$See_also"
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
				Synopsis='' Desc='' Defaults='' Depends='' Example='' See_also='' Tags=''
	
			elif [[ "${SubHdrs[@]}" == *"$label"* ]]; then  # check if new label is a subheader category
				#msg.info "  subheader [$label] found"
				v="${label}+=\${cmt}\"\${LF}\""
				eval "$v"
			else
				msg.err "File [$file]:" "  bad label [$label]: Label not found in categories/subheaders."
			fi
	
			oldlabel=$label
		done
	done

	# make symlinks in the help root to canonical files in category directories
	msg.info 	"Making symlinks in [$HelpFilesDir]" 
	msg.info	"  to files in category directories."
	cd "$HelpFilesDir" || msg.die "Could not cd into [$HelpFilesDir]"
	for c in $(find -L . -mindepth 1 -type f); do 
		target="${c:2}"
		ln -fs "$target" "$(basename "$target")" >/dev/null
	done 

	tab.set 0
	msg "$PRG finished"
	return 0
}

	
cleanup() {
	[[ $1 == '' ]] && exitcode=$? || exitcode=$1
	exit $exitcode
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

usage() {
	cat <<-usage
		$PRG
		Create entities help files.
		Usage: $PRG [--auto|-y] [--verbose|-v || --quiet|-q] [--help|-h]
	usage
	exit 1
}
main "$@"
#fin
