#!/bin/bash
# shellcheck source=entities.bash.min
source "$(dirname "$0")/entities.bash.min" new || { echo >&2 "Could not open [$(dirname "$0")/entities.bash]."; exit 1; }
	trap.set on
	strict.set off
	version.set "${_ent_VERSION}"
	msg.usetag.set off
	msg.prefix.set 'entitites.help.make'
		
	declare EntitiesDir
	EntitiesDir="${PRGDIR:-}"
	[[ -z $EntitiesDir ]] && msg.die "No dir [$EntitiesDir]"
	# sanity check
	[[ "$(basename "$EntitiesDir")" == 'entities' ]] || msg.die "Sanity check fail."
	
	declare HelpFilesDir="${EntitiesDir}/docs/help"

	# Canonical Category Labels
	declare -ura CatHdrs=(
			ABOUT
			GLOBALVAR
			FUNCTION
			SCRIPT
			PROGRAM
			REFERENCE
		)

	# Canonical Subheader Labels
	declare -ura SubHdrs=(
			AUTHOR
			BUGS
			COPYRIGHT
			DEFAULTS
			DEPENDS
			DESC
			ENVIRON
			EXAMPLE
			FILES
			OPTIONS
			SEE_ALSO
			SYNOPSIS
			TAGS
			TODO
			VERSION
		)

	# transpostion aliases
	declare -urA TransHdrs=(
			[FUNC]='FUNCTION'
			[GLOBAL]='GLOBALVAR'
			[GLOBALX]='GLOBALVAR'
			[INTRO]='ABOUT'
			[INTRODUCTION]='ABOUT'
			[REF]='REFERENCE'

			[BUG]='BUGS'
			[BY]='AUTHOR'
			[COPYLEFT]='COPYRIGHT'
			[DEF]='DEFAULTS'
			[DEFS]='DEFAULTS'
			[DESCRIPTION]='DESC'
			[EG]='EXAMPLE'
			[ENV]='ENVIRON'
			[ENVIRONMENT]='ENVIRON'
			[EXAMPLES]='EXAMPLE'
			[EX]='EXAMPLE'
			[FILE]='FILES'
			[OPTS]='OPTIONS'
			[REQ]='DEPENDS'
			[REQUIRE]='DEPENDS'
			[REQUIRES]='DEPENDS'
			[SEE]='SEE_ALSO'
			['SEE ALSO']='SEE_ALSO'
			[TAG]='TAGS'
			[USE]='SYNOPSIS'
			[USAGE]='SYNOPSIS'
			[USEAGE]='SYNOPSIS'
			[VER]='VERSION'
		)

	declare -i HelpColWidth=66
	
main() {
	local SourceFile HelpOutputFile=''
	local -a DocLines
	local DocLine txt lbl sx
	local -a symlinks=()

	rm -rf "${HelpFilesDir:-:}/"

	"$EntitiesDir"/scripts/entities.scripts.create-help -y \
			|| msg.die "Could not execute entities.scripts.create-help"
	
	# find all .bash and .c files
	mapfile -t bashfiles < <(find "$EntitiesDir/" \( -name "*.bash" -o -name "*.c" \) -type f \
								| grep -v '/docs/\|.gudang\|.min\|/dev/\|/test/\|/_')
	# go through them one-by-one ...
	for SourceFile in "${bashfiles[@]}"; do
		msg.info "Searching [${SourceFile/${EntitiesDir}\//}]"
		mapfile -t DocLines < <(grep '^#X[[:blank:][:alnum:]._-]*:[[:blank:]]' "$SourceFile")
		for	DocLine in "${DocLines[@]}"; do
			txt=$(rtrim "${DocLine#*:[[:blank:]]}")
			#[[ -z $txt ]] && continue
			lbl=${DocLine%%:*}; lbl=${lbl^^}
			lbl=$(trim "${lbl:2}")
			if [[ -n $lbl ]]; then
				# transpose aliases
				# shellcheck disable=SC2102
				[[ -v TransHdrs[$lbl] ]] && lbl=${TransHdrs[$lbl]}
				# has HEADER changed? Then change the HelpOutputFile
				if [[ " ${CatHdrs[*]} " == *" $lbl "* ]]; then
					# say goodbye to current HelpOutputFile
					[[ -n $HelpOutputFile ]] && \
							print2OutputFile 'URL'  "file://${SourceFile//\/\//\/}"
					# close current HelpOutputFile

					# open new HelpOutputFile ===================
					Label=$lbl
					Header=$txt
					mkdir -p "$HelpFilesDir/$Label" || msg.die "mkdir [$HelpFilesDir/$Label] failed."
					read -r -a symlinks <<<"$Header"
					HelpOutputFile="$HelpFilesDir/$Label/${symlinks[0]}"
					rm -f "$HelpOutputFile"
					#print2OutputFile 'SOURCE' "${SourceFile/${EntitiesDir}\//}"
					# if more than one entry in Header, then make symlinks to first entry.
					for sx in "${symlinks[@]:1}"; do
						(	cd "$HelpFilesDir/$Label" || msg.die "cd [$HelpFilesDir/$Label] failed."		# catastophic error that Must Not Happen
							ln -fs "${symlinks[0]}" "${sx}"
						)
					done
				elif [[ " ${SubHdrs[*]} " == *" $lbl "* ]]; then
					Label=$lbl #???	
				else
					msg.warn "Unknown Help Label [$lbl] in [$SourceFile]"
				fi
			fi
			print2OutputFile "${lbl:0:11}" "${txt}"
		done
		# say goodbye to current HelpOutputFile
		print2OutputFile 'URL' "file://$SourceFile"
		# close current HelpOutputFile
		HelpOutputFile=''
		# say goodbye to Label
		Label=''
		Header=''
	done

#	# make symlinks in the help root to canonical files in category directories
#	msg.info 	"Making symlinks in [$HelpFilesDir]" 
#	msg.info	"  to files in category directories."
#	cd "$HelpFilesDir" || msg.die "Could not cd into [$HelpFilesDir]"
#	mapfile -t symlinks < <(find -L . -mindepth 1 -type f)
##	read -r -a symlinks < <(find -L . -mindepth 1 -type f)
#	for sx in "${symlinks[@]}"; do 
#		sx="${sx:2}"
#		ln -fs "$sx" "$(basename "$sx")" >/dev/null
#	done 

	msg.info "Done"
	return 0
}

print2OutputFile() {
	local lbl="${1:-}" txt="${2:-}"
	local -a WR
	if [[ -z $HelpOutputFile ]]; then
		msg.warn "No Output File for [$lbl]:[$txt]"
		return 0
	fi
	txt=$(expand -t 2 <<<"$txt")
	mapfile -t WR < <(fold -w "$HelpColWidth" -s <<<"$txt")
	lbl="${lbl,,}"
	for txt in "${WR[@]}"; do
		printf '%10s: %s\n' "${lbl^}" "$txt" >>"$HelpOutputFile"
		lbl=''
	done
	return 0
}

main "$@"
#fin
