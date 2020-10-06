#!/bin/bash
#! shellcheck disable=SC2034,SC2154,
#X Function: chgConfigVar
#X Desc    : Add or Change a Variable defined within a file, typically
#X         : a system configuration file. New values are always enclosed
#X         : using ''. Space indents are ignored. One line, one variable.
#X         :
#X Synopsis: chgConfigVar "file" VAR "value" [ VAR "value"...] [!VAR...]
#X         : Change entry for VAR in "file" to new "value".
#X         : If "file" does not exist, it is created, regardless of
#X         : whether there are any further parameters.
#X         : If [!] is prefixed to VAR ('!VAR'), then VAR is removed from 
#X         : "file".
#X         :
#X Example : chgConfigVar environment OKROOT '/usr/share/okusi' '!TIME_STYLE'
#X         :
#X         : chgConfigVar ~/.profile.name TIME_STYLE '+%Y-%m-%d %H:%M'
chgConfigVar()	{
	local Profile=${1:-} key
	shift
	if [[ ! -f $Profile ]]; then
		cat >"$Profile" <<-etx
		#!/bin/bash
		#! shellcheck disable=SC2034
		#  [$Profile] created $(date +'%F %T')$( [[ ! -z ${PRG:-} ]] && echo " by $PRG" )
		etx
	fi
	while (($#)); do
		key="$1"
		if [[ "${key:0:1}" == '!' ]]; then
			sed -i "/^\s*${key:1}=.*/d" "$Profile"
			shift; continue
		fi
		keyval="$key='${2:-}'"
		if grep -q "^[[:blank:]]*${key}=" "$Profile"; then
			sed -i "s!^\s*${key}=.*!${keyval}!" "$Profile"
		else
			echo "$keyval" >>"$Profile"
		fi
		shift; (($#)) && shift
	done
}
declare -fx chgConfigVar
#fin
