#!/bin/bash
#X Function: perrno
#X Desc    : Return text of OS or MySQL error codes.
#X Synopsis: perrno errnumber [os|mysql]
#X         :   os|mysql  If not specifed, error codes for both OS and MySQL
#X         :             are display.
#X Example : perrno 127 os    # returns text of err 127 in OS
#X         : perrno 127 mysql # returns text of err 127 in MySQL
#X         : perrno 127       # returns texts of err 127 in both OS and MySQL
#X         : mysql mydatabase || perrno $? mysql
declare -x _ent_perrnoListFile="${ENTITIES:-/lib/include/entities}/docs/perrno.list"
perrno() {
	(($#)) || return 0 
	local OS=${2:-}
	[[ ! -f ${_ent_perrnoListFile} ]] && _perrno_gen_errors
	grep -i "$OS ${1}\:" "${_ent_perrnoListFile}" 2>/dev/null
	return 0
}
	_perrno_gen_errors() {
		(
			local -i i=0
			local t IFS=$'\n'
			if [[ ! -d $(dirname "${_ent_perrnoListFile}") ]]; then
				mkdir -p "$(dirname "${_ent_perrnoListFile}")"
			fi
			> "${_ent_perrnoListFile}"
			while ((i<513)); do 
				t="$(perror $i)"
				t="${t// error code/}"
				t="${t/  / }"
				[[ -n "$t" ]] && echo "$t" >> "${_ent_perrnoListFile}"
				((i++))
			done
		) &>/dev/null
		return 0
	}

declare -fx perrno
#fin
