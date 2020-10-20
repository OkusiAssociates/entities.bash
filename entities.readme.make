#!/bin/bash
#! shellcheck disable=SC1090,2034
PRG=$(basename "$0")
PRGDIR=$(dirname "$(readlink -f "$0")")

	ENTITIES="$PRGDIR"

	source "$ENTITIES/entities.bash.min" new || exit 2

	cat <<-'eot'
	# Entities.bash Environment/Function Library
	###### Version [$_ent_VERSION]
	
	Entities.bash is a lightweight Bash scripting environment and library for systems and network administrators who use `Ubuntu 18.04` or higher.
	
	The philosophy is to be simple, unobtrusive, flexible, with minimal dependencies, while providing a standard functionality across an entire network environment.
	
	### Entities.bash requires:
	
		* Ubuntu 18.04, or higher
		* Bash 4.4, or higher
	
		Use on non-Ubuntu systems should be possible with minimal changes.  
	
	### Quick Install:
	
	    sudo git clone https://github.com/OkusiAssociates/entities.bash.git && entities.bash/entities.install -y
	
	### Invocation
	
	To invoke `entities`, just enter `source entitites` at the top of your script, or invoke it at the command line.
	````
	    source entities new
	    msg "Hello World"
	    entities help
	````
	Once loaded into the environment `entities` can be invoked without reloading the entire library.
	
	If `entities` is already loaded at the time a script is run, it is not loaded again, greatly speeding up load and execution time for downstream scripts that also use `entities` library functions.
	
	### Functions
	
	Current functions:
	
	eot

	declare -a arr
	mapfile -t arr < <("$ENTITIES"/entities.show -f)
	for f in "${arr[@]}"; do 
		echo -n '`'"$f"'`'' '
	done
	echo
	
	cat <<-'etx'
	### Script/Function Templates

	Scripting templates are an important part of a programmer's armory.  `entitities.bash` comes with several simple but powerful templates for new scripts, or functions.  Here are the ones used most frequently:

	etx

	for f in "$ENTITIES"/docs/templates/*.bash; do
		[[ $f == *primitive* ]] && continue
		echo '#### Template `'"$(basename "$f")"'`'
		echo '````'
		expand -t 2 "$f"
		echo '````'
		echo
	done

	cat <<-'etx'
	### Scripts

	etx

	for f in "$ENTITIES"/scripts/**; do
		[[ -d $f ]] ||	[[ ! -x $f ]] || [[ $f == *entities.*  ]] && continue
		echo '#### Script `'"$(basename "$f")"'`'
		echo '````'
		"$f" --help 2>&1 | expand -t 2
		echo '````'
		echo
	done

	cat <<-'etx'
	### Help
	
	See `entities help` for full documentation.
	
	### Developers
	
	Are you a bash programmer? If you would like to assist with this project, go to the repository at:
	
	    http://github.com/OkusiAssociates/entities.bash
	
	Bugs/Features/Reports/Requests/Criticism send to `garydean@linux.id`
	
	etx
