#!/bin/bash
declare -x perrnoListFile="${ENTITIES:-/lib/include/entities}/docs/perrno.list"

#X Function: perrno
#X Desc    : return text of OS or MySQL error codes
#X Synopsis: perrno errnumber [os|mysql]
#X Example : perrno 127 os		# returns text of err 127 in OS
#X         : perrno 127 mysql	# returns text of err 127 in MySQL
#X         : perrno 127 os		# returns texts of err 127 in both OS and MySQL
perrno() {
	(($#)) || return 0 
	local OS=${2:-}
	[[ ! -f $perrnoListFile ]] && _perrno_gen_errors
	grep -i "$OS ${1}\:" "$perrnoListFile"
	return 0
}
	_perrno_gen_errors() {
		(
		local -i i=0
		local t IFS=$'\n'
		if [[ ! -d $(dirname "$perrnoListFile") ]]; then
			mkdir -p "$(dirname "$perrnoListFile")"
		fi
		> "$perrnoListFile"
		while ((i<500)); do 
			t="$(perror $i)"
			t="${t// error code/}"
			t="${t/  / }"
			[[ -n "$t" ]] && echo "$t" >> "$perrnoListFile"
			((i++))
		done
		) &>/dev/null
		return 0
	}
#fin
