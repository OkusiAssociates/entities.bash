#!/bin/bash
source $OKROOT/entities/entities.bash || { echo >&2 "$0: source file \$OKROOT/entities/entities.bash not found!"; exit 1; }
strict.set on
declare -i auto=0

main() {
	while (($#)); do
		case "$1" in
			-q|--quiet)		verbose.set off;;
			-v|--verbose)	verbose.set on;;
			--auto|-y)		auto=1;;
			*)						msg.die "Bad parameter $1";;
		esac
		shift
	done

  if ((auto)); then
    color.set off
  fi

	cwd=$(pwd)	
	cd "$PRGDIR" || msg.die "could not cd into '$PRGDIR'!"

	templates=( 'entities.bash' )

	msg.info "Entities for Bash - Make Minimal Versions"
	if ((!auto)); then
		tab.set ++
		msg.info ""
		msg.info "Create minimal versions of standard bash include files"
		msg.info "without comments, blank lines and leading space."
		msg.info "minimal include files are named *.min.bash"
		msg.info ""
		ask.yn "Do you wish to proceed?" || exit 1
		msg ''
		tab.set --
	fi
	tab.set ++

	if [[ "$OKROOT" == '' ]]; then msg.die "\$OKROOT not defined!"
														else path="$OKROOT/entities"
	fi
	cd "$path" || msg.die "Could not cd into '$path'!"
	
	for template in ${templates[@]}; do
		template=$(basename "$template" '.bash')
		mintemplate="$path/$template.min.bash"

		[[ ! -f "${template}.bash" ]] && msg.die "${template}.bash not found!"

		# remove #comment lines that begin with [space*]#
		tx=$(grep -v '^$' "$path/$template.bash" | grep -v '^[[:space:]]*#')

		# make the minimal version of entities.bash	
		echo '#!/bin/bash' > "$mintemplate"
		(
			local IFS=$'\n'
			for ln in $tx; do
				echo $(trim "$ln") >> $mintemplate
			done
		)

		# make timestamps the same for *.bash and *.min.bash
		/usr/bin/touch -r "$path/$template.bash" "$mintemplate" || msg.die "File touch $mintemplate failed!"
		
		# check permissions
		chmod 644 "$mintemplate"	|| msg.die "Could not chmod $mintemplate!"

		msg.sys log "$mintemplate created."
	done

	# symlinks
	cd "$cwd" || msg.die "Could not cd to $cwd!"
}

main $@
#fin
