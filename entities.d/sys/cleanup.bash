#!/bin/bash
#! shellcheck disable=SC2154
#X Function : cleanup
#X Desc     : a call to this function is made in the trap EXIT command.
#X          : on exiting the script this function will always be called.
#X          : you should define your own cleanup function to delete temporary
#X          : files and other detritus before terminating.
#X          : if you are not using the exit_if_already_running function
#X Synopsis : cleanup [exitcode] [_LINENO_]
#X Example  : cleanup
#X See Also : trap.set trap.function, exit_if_already_running
cleanup() {
	local -i exitcode=$?
	if ((exitcode)); then
		if ((_ent_DEBUG)); then
			msg.info "Debug [${PRG:-}]:"
			msg.info "$(set | grep ^_ent_)"
			msg.info "$(set | grep ^BASH	| grep -v BASH_VERSINFO)"
		fi
		if ((exitcode > 1)) && ((_ent_DEBUG)); then
			msg.err "script=[${PRG:-}] 
							exit=[$exitcode] 
							line=[${2:-}] 
							\$1=[${1:-}] 
							fn[]=[${FUNCNAME[*]// /\|}]
							ln=[${BASH_LINENO[*]:-}]
							bs=[${BASH_SOURCE[*]:-}]"
		fi
	fi
	exit "$exitcode"
}
declare -fx cleanup
#fin
