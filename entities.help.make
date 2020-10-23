#!/bin/bash
#! shellcheck disable=SC2034
source "$(dirname "$0")/entities.bash.min" new || { echo >&2 "Could not open [$(dirname "$0")/entities.bash]."; exit 1; }
	strict.set off
	# shellcheck disable=SC2154
	version.set "${_ent_VERSION}"
	msg.prefix.set "$(msg.prefix.set)help.make"
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
#     ENVIRONMENT
#     FILES
#     EXAMPLES
#     AUTHOR
#     REPORTING BUGS
#     COPYRIGHT
#     SEE ALSO

	# Category Labels
	declare -a CatHdrs=( 
			About
			Globalx
			Global
			Local
			Function
			Script
			File
			)
	# Subheader Labels
	declare -a SubHdrs=(
			Version
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
					Version=''	\
					Synopsis='' \
					Desc='' 		\
					Defaults='' \
					Depends='' 	\
					Example=''  \
					See_Also='' \
					Tags=''			\
					Source=''

	declare -a Symlinks=()

	declare -i auto=0 wipe=0

	declare dashes='----------------------------------------------------------------------------'
	
main() {
	exit_if_not_root
#	exit_if_already_running
	declare label='About' oldlabel='' lbl='' cmt=''
	local IFS=$'\n'

	cmd=()
	while (($#)); do
		case "$1" in
			-y|--auto)			auto=1; wipe=1;;
			-h|--help)			usage;;
			-V|--version)		version.set; return 1;;
			-v|--verbose)		msg.verbose.set on;;
			-q|--quiet)			msg.verbose.set off=;;
			*)							cmd+=( "$1" );;
		esac
		shift
	done

	if ((auto)); then
		msg.verbose.set off
		msg.color.set off
	fi

	msg "$PRG for entities.bash"
	msg.tab.set ++
	msg "Create help pages from canonical entities.bash file to " "directory $HelpFilesDir." 
	if ((!auto)); then
		msg.yn --warning "Do you wish to proceed?" || exit 1
		echo
	fi
	if ((!auto)); then
		msg.yn --warning "Wipe the [${HelpFilesDir//${EntitiesDir}/}] directory?" && wipe=1
		echo
	fi
	if ((wipe)); then
		msg.info "Deleting all files in [$HelpFilesDir]..."
		rm -rf "${HelpFilesDir:?}/"
		mkdir -p "$HelpFilesDir"
	fi

	"$EntitiesDir/scripts/entities.scripts.create-help" -y \
		|| msg.die "Could not execute entities.scripts.create-help"

	bashfiles="$(find "$EntitiesDir/" \( -name "*.bash" -o -name "*.c" \)  -not -name "_*" -type f \
								| grep -v '/docs/\|.gudang\|.min\|/dev/\|/test/')"
	for file in ${bashfiles[@]}; do
		msg.info "Searching [${file/${EntitiesDir}\//}]..."
		hlp="$(grep '^#X\+' "$file" | grep ':')"
		for hline in ${hlp[@]}; do 
			lbl=$(str_str "$hline" '#X' ':')
			lbl=$(trim "$lbl")
			lbl=${lbl/ /_}
			# normalise to Title case
			lbl=$(titlecase "$lbl")
			[[ ${lbl} =~ ^Us[e]*age ]] && lbl='Synopsis'
			[[ $lbl == 'Examples' || $lbl == 'Eg' ]] 						&& lbl='Example'
			[[ $lbl == 'Requires' || $lbl == 'Dependencies' ]]	&& lbl='Depends'
			
			cmt="${hline#*:[[:blank:]]}"
			cmt=$(rtrim "$cmt")
			[[ -z "$cmt" ]] && continue
			if [[ -z "$lbl" ]]; then
				v="${label}+=\"\${cmt}\"\${LF}\"\""
				eval "$v"
				continue
			fi
			
			# change labels
			label=$(titlecase "$lbl") 
			if [[ "${CatHdrs[*]}" == *"${label}"* ]]; then  # check if new label is a header category
				#msg.info "header [$label] found"
			FinishFile="$file"
				if (( ${#Label} )); then
					destdir="$HelpFilesDir/$Label"
					mkdir -p "$destdir"
					declare -a Symlink=()
					IFS=$' \t';	Symlink=( $Header ); IFS=$'\n'
					#msg.info "#write $label out to file $Label:$destdir"
					endtag="$Label-"
					sx=$((10 - ${#endtag} ))
					endtag+="-${Symlink[0]}"
					endtag=$(printf "#%${sx}.${sx}s%s" "$dashes" "$endtag")
					(	echo "${endtag}"
						printlines "$Label"  	"$Header"
						printlines 'Version'	"$Version"
						printlines 'Tags' 		"$Tags"
						printlines 'Desc' 		"$Desc"
						printlines 'Synopsis' "$Synopsis"
						printlines 'Defaults' "$Defaults"
						printlines 'Depends' 	"$Depends"
						printlines 'See_Also' "$See_Also"
						printlines 'Example' 	"$Example"
						printlines 'Source'  	"$FinishFile"
						sx=$(( 76-${#endtag} ))
						printf "%s--%${sx}.${sx}s%s" "$endtag" "$dashes" "$LF"
					) > "$destdir/${Symlink[0]}"
	
					IFS=$' \t\n'
					for s in ${Symlink[@]:1}; do
						cd "$destdir" || return 1
						ln -fs "${Symlink[0]}" "${s}"
						cd - >/dev/null
					done
					IFS=$'\n'
				fi
				Label="$label"
				Header="$cmt"
				Synopsis='' Version='' Desc='' Defaults='' Depends='' Example='' See_Also='' Tags='' Source=''
	
			elif [[ "${SubHdrs[@]}" == *"$label"* ]]; then  # check if new label is a subheader category
				#msg.info "  subheader [$label] found"
				v="${label}+=\${cmt}\"\${LF}\""
				eval "$v"
			else
				msg.err "File [$file]:" "  bad label [$label] not found in categories/subheaders."
			fi
	
			oldlabel=$label
		done
		FinishFile="$file"
	done

	# make symlinks in the help root to canonical files in category directories
	msg.info 	"Making symlinks in [$HelpFilesDir]" 
	msg.info	"  to files in category directories."
	cd "$HelpFilesDir" || msg.die "Could not cd into [$HelpFilesDir]"
	for c in $(find -L . -mindepth 1 -type f); do 
		target="${c:2}"
		ln -fs "$target" "$(basename "$target")" >/dev/null
	done 

	msg.tab.set 0
	msg "$PRG finished"
	return 0
}
	
cleanup() {
	[[ $1 == '' ]] && exitcode=$? || exitcode=$1
	exit "$exitcode"
}

printlines() {
	local label content l
 	local IFS=$'\n'	
	label=$(trim "${1:-}")
	content=$(trim "${2:-}")
	[[ -z "$content" ]] && return 0
	for l in $content; do
		l="$(echo "$l" | expand -t 2)"
		printf '%10.10s: %s\n' "$label" "$l"
		label=''
	done
}

usage() {
	cat <<-usage
		Script  : $PRG
		Desc    : Create entities.bash help files.
		Synopsis: $PRG [-y] [-v][-q] [-V] [-h]
		        :   -y|--auto
		        :   -v|--verbose
		        :   -q|--quiet
		        :   -V|--verbose
		        :   -h|--help
	usage
	exit 1
}
main "$@"
#fin
