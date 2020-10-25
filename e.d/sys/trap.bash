#X Function : trap.function
#X Synopsis : trap.function [{ bash_exit_trap_function } ]
#X See Also : trap.set
# shellcheck disable=SC2016
declare -x _ent_EXITTRAPFUNCTION='{ cleanup $? ${LINENO:-0}; }'
trap.function() {
	if (($#));	then 
		_ent_EXITTRAPFUNCTION="$1" 
	else 
		echo -n "$_ent_EXITTRAPFUNCTION"
	fi
	return 0
}
declare -fx 'trap.function'

#X Function : trap.set
#X Synopsis : trap.set [[on|1] | [off|0]]
declare -ix _ent_EXITTRAP=0
trap.set() {
	if (( $# )); then
		_ent_EXITTRAP=$(onoff "${1}" ${_ent_EXITTRAP})
		if ((_ent_EXITTRAP)); then
			#-- SC2064: Use single quotes, otherwise this expands now rather than when signalled.
			# shellcheck disable=SC2064
			trap "$_ent_EXITTRAPFUNCTION" EXIT
		else
			trap -- EXIT
		fi
	else
		echo -n "${_ent_EXITTRAP}"
	fi
	return 0
}
declare -fx 'trap.set'
#fin
