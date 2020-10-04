#!/bin/bash
# global shellcheck 'disables' used by 'p' editor
#! shellcheck disable=SC1090

# entities.bash - Bash programming environment and library
# Copyright (C) 2019-2020  Gary Dean <garydean@okusi.id>
# 
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
# 
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
# 
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <https://www.gnu.org/licenses/>.
# 
# Okusi Associates
#   https://okusiassociates.com
#   https://github.com/OkusiAssociates/entities.bash
# Gary Dean
#   https://garydean.id

#X About  : entities.bash
#X Desc   : Entities Functions/Globals/Local Declarations and Initialisations.
#X        : entities.bash is a light-weight Bash function library for systems
#X        : programmers and administrators.
#X        : _ent_LOADED is set if entities.bash has been successfully loaded.
#X        : PRG=basename of current script. 
#X        : PRGDIR=directory location of current script, with softlinks 
#X        : resolved to actual location.
#X        : PRG/PRGDIR are *always* initialised as local vars regardless of 
#X        : 'inherit' status when loading entities.bash.
#X Depends: basename dirname readlink mkdir ln cat stty

#X Global  : PRG PRGDIR 
#X Desc    : PRG and PRGDIR are global variables reinitialised every time 
#X         : entities.bash is sourced/executed.
#X Examples: source entities.bash inherit 
#X         :       # ^ if entities.bash has already been loaded, 
#X         :       # init PRGDIR/PRG globals only then return.
#X         :       # if entities.bash has not been loaded, load it.
#X         :       # [inherit] is the default. 
#X         : source entities.bash new 
#X         :       # ^ load new instance of entities.bash; 
#X         :       # do not use any existing instance already loaded.
declare -- PRG PRGDIR 

declare -x _ent_scriptstatus="[\$0=$0]"

	declare p_
	# Is entities.bash being executed as a script?
	if ((SHLVL > 1)) || [[ ! $0 == ?'bash' ]]; then
		p_="$(/bin/readlink -fn -- "${0}")" || p_=''
		_ent_scriptstatus+="[is.script][\$p_=$p_]"
		# Has entities.bash been executed?
		if [[ "$(/bin/readlink -fn -- "${BASH_SOURCE[0]:-}")" == "$p_" ]]; then
			_ent_scriptstatus+='[is.execute]'
			_ent_LOADED=0
			# do options for execute mode
			while (( $# )); do
				case "${1,,}" in
					help|/\?|-\?|-h|--help)	
								"${ENTITIES:-/lib/include/entities}/entities.help" "${@:2}"
								exit $?
								break;;
					# All other passed parameters return error.
					-*)		echo >&2 "$(basename "$0"): Bad option [$1]";		exit 22;;
					*)		echo >&2 "$(basename "$0"): Bad argument [$1]";	exit 22;;
				esac
				shift
			done		
			exit $?
		fi
		_ent_scriptstatus+='[is.sourced-from-script][SHLVL='"$SHLVL"']'
		PRG=$(/usr/bin/basename "${p_}")
		PRGDIR=$(/usr/bin/dirname "${p_}")
		_ent_scriptstatus+="[PRGDIR=$PRGDIR]"
		unset p_

		# `entities` is already loaded, and no other parameters have 
		# been given, so do not reload.
		if (( ! $# )); then
			(( ${_ent_LOADED:-0} )) && return 0
		fi
	
	# `source entities` has been executed at the shell command prompt
	else
		_ent_scriptstatus+='[sourced-from-shell][SHLVL='"$SHLVL"']'
		p_=$(/bin/readlink -fn -- "${BASH_SOURCE[0]}")
		PRG=$(/usr/bin/basename "${p_}")
		PRGDIR=$(/usr/bin/dirname "${p_}")
		_ent_scriptstatus+="[PRGDIR=$PRGDIR]"
		unset _p
		if [[ -n "${ENTITIES:-}" ]]; then
			PATH="${PATH//\:${ENTITIES}/}"
			PATH="${PATH//\:\:/\:}"
		fi
		export ENTITIES="$PRGDIR"
		export PATH="${PATH}:${ENTITIES}"		
		_ent_LOADED=0		# always reload when sourced from command line
	fi

	# there are parameters
	while (( $# )); do
		case "${1,,}" in
			# new load
			new)			_ent_LOADED=0;;
			# Does the calling script wish to inherit the current 
			# Entities.bash environment/functions?
			# Inherit is the default. Can only inherit if called from a script.
			inherit)	_ent_LOADED=${_ent_LOADED:-0};;
			# all other passed parameters are ignored (possibly script parameters? 
			# but not for entities)
			*)				break;;
		esac
		shift
	done

#X Global  : _ent_LOADED
#X Desc    : _ent_LOADED global flags whether entities.bash has 
#X         : already been loaded or not. If it has, then it exit 
#X         : straight away.
#X Example : (( ${_ent_LOADED:-0} )) \
#X         :     || { echo >&2 'entities.bash not loaded!'; exit; }
((_ent_LOADED)) && return 0;

_ent_scriptstatus+='[reloading]'

# turn off 'strict' by default
set +o errexit +o nounset +o pipefail

# oh why not ...
shopt -s extglob
shopt -s globstar

#X GlobalX : CR CH9 LF OLDIFS IFS
#X Desc    : Constant global char values.
#X         : NOTE: IFS is 'normalised' on every 'new' execution of 
#X         :       entities. OLDIFS retains the existing IFS.
#X Synopsis: CR=$'\r' CH9=$'\t' LF=$'\n' OLDIFS="$IFS" IFS=$' \t\n'  
#X Defaults: OLDIFS=$IFS    # captures existing IFS before assigning 
#X         :                # 'standard' IFS.
#X         : IFS=$' \\t\\n' # standard IFS
#X Example : str="${LF}${CH9}This is a line.${LF}{$CH9}This is another line."
#X         : echo -e "$str"
declare -x	CR=$'\r' CH9=$'\t' LF=$'\n'
declare -x	OLDIFS="$IFS" IFS=$' \t\n'
declare -nx	OIFS='OLDIFS'

#X Function: onoff 
#X Desc    : echo 1 if 'on', 0 if 'off'
#X Synopsis: onoff on|1 || off|0 [defaultval]
#X         : for ambiguous value, returns defaultval if defined, otherwise 0.
#X Example : result=$(onoff off 1)
onoff() {
	local o="${1:-0}"
	case "${o,,}" in
		on|1)			o=1;;
		off|0)		o=0;;
		*)				o=0; (( $# > 1 )) && o=$(( ${2} ));; 
	esac
	echo -n $((o))
	return 0
}
declare -fx 'onoff'

declare -ix _ent_VERBOSE
[ -t 1 ] && _ent_VERBOSE=1 || _ent_VERBOSE=0
#X Function: verbose.set is.verbose
#X Desc    : Set global verbose status for msg* functions. For shell 
#X         : terminal verbose is ON by default, otherwise, when called 
#X         : from another script, verbose is OFF by default.
#X         : verbose.set() status is used in the msg.yn() and some msg.*() 
#X         : commands, except msg.sys(), msg.die() and msg.crit(), which will 
#X         : always ignore verbose status and output to STDERR.
#X Synopsis: verbose.set [on|1] | [off|0]
#X         : curstatus=$(verbose.set)      
#X         : is.verbose returns true if verbose is set, false if not.
#X Example : 
#X         : oldverbose=$(verbose.set)
#X         : verbose.set on
#X         : # do stuff... #
#X         : verbose.set $oldverbose
#X         : is.verbose && echo "Verbose is on."
#X         : _ent_VERBOSE controls output from msg*() functions.
is.verbose() { return $(( ! _ent_VERBOSE )); }
declare -fx 'is.verbose'
	alias verbose='is.verbose' #X legacy X#
	
verbose.set() {
	if (( ${#@} )); then
		_ent_VERBOSE=$(onoff "${1}")
	else
		# shellcheck disable=SC2086
		echo -n ${_ent_VERBOSE}
	fi
	return 0
}
declare -fx 'verbose.set'

#X Function: color.set is.color
#X Desc    : turn on/off colorized output from msg.* functions.
#X         : Color is turned off if verbose() is also set to off.
#X Synopsis: color.set [ON|1][OFF|0][auto]
#X         : curstatus=$(color.set)
#X Example : 
#X         : oldstatus=$(color.set)
#X         : color.set off
#X         : # do stuff... #
#X         : color.set $oldstatus
declare -ix _ent_COLOR=1
[ -t 1 ] && _ent_COLOR=1 || _ent_COLOR=0
is.color() { return $(( ! _ent_COLOR )); }
declare -fx 'is.color'
	alias is.colour='is.color'		# for the civilised world
	alias color='is.color'
	
color.set() {
	if (( ${#@} )); then 
		if [[ $1 == 'auto' ]]; then
			[ -t 1 ] && status=1 || status=0
		else
			status=$1
		fi
		_ent_COLOR=$(onoff "${status}" "${_ent_COLOR}")
	else 
		echo -n "${_ent_COLOR}"
	fi
	return 0
}
declare -fx 'color.set'
	alias colour.set='color.set'		# for the civilised world

#X GlobalX  : colorreset colordebug colorinfo colornotice colorwarning colorerr colorcrit coloralert coloremerg
#X Desc     : Colors used by entities msg.* functions.
#X          : emerg alert crit err warning notice info debug
#X          : panic (dep=emerg) err (dep=error) warning (dep=warn)
#X See Also :
declare -x colorreset="\x1b[0;39;49m"
declare -x color0="\x1b[0;39;49m"
declare -x colordebug="\x1b[35m"
declare -x colorinfo="\x1b[32m"
declare -x colornotice="\x1b[34m"
declare -x colorwarning="\x1b[33m";					declare -nx colorwarn='colorwarning'
declare -x colorerr="\x1b[31m";							declare -nx colorerror='colorerr'
declare -x colorcrit="\x1b[1;31m";					declare -nx colorcritical='colorcrit'
declare -x coloralert="\x1b[1;33;41m"
declare -x coloremerg="\x1b[1;4;5;33;41m";	declare -nx colorpanic='coloremerg'

#X Function : version.set
#X Desc     : Set or return version number of the current script.
#X Defaults : '0.0.0'
#X Synopsis : version.set "verstring"
#X          : $(version.set)
#X Example  : version.set '4.20'	# set script version.
#X          : version.set					# print current script version.
#X          : ver=$(version.set)	# store current version setting to variable.
declare -x _ent_SCRIPT_VERSION='0.0.0'
version() { echo -n "$_ent_SCRIPT_VERSION"; return 0; }
declare -fx 'version'
version.set() {
	if (( ${#@} )); then _ent_SCRIPT_VERSION="$1"
								else echo -n "${_ent_SCRIPT_VERSION}"
	fi
	return 0
}
declare -fx 'version.set'

#X Function: dryrun.set is.dryrun
#X Desc    : general purpose global var for debugging. 
#X Defaults: 0
#X Synopsis: dryrun.set [[on|1] | [off|0]]
#X         : $(dryrun.set)
#X Example : dryrun.set off
#X         : is.dryrun || doit.bash
declare -ix _ent_DRYRUN=0
is.dryrun() { return $(( ! _ent_DRYRUN )); }
declare -fx 'is.dryrun'
	alias dryrun='is.dryrun'

dryrun.set() {
	if (( $# )); then 
		_ent_DRYRUN=$(onoff "${1}" "${_ent_DRYRUN}")
	else 
		#	-- SC2086: Double quote to prevent globbing and word splitting.
		# shellcheck disable=SC2086
		echo -n ${_ent_DRYRUN}
	fi
	return 0
}
declare -fx 'dryrun.set'

#X Function: debug.set is.debug
#X Desc    : General purpose globalx setting for debugging. 
#X         : debug.set sets the debug value (0|1) when a 
#X         : parameter is passed. If a parameter is not passed, 
#X         : the current status of debug is echoed.
#X         : debug is a conditional test function, returning 
#X         : !(debug.set).
#X Defaults: 0|off
#X Synopsis: debug.set [[on|1] | [off|0]]
#X         : $(debug.set)
#X         : debug
#X Example : debug.set on
#X         : debug && msg "my debug message"
#X         : olddebug=$(debug.set)
declare -ix _ent_DEBUG=0
is.debug() {	return $(( ! _ent_DEBUG )); }
declare -fx 'is.debug'
	alias debug='is.debug' #X legacy X#
	
debug.set() {
	if (( $# )); then _ent_DEBUG=$(onoff "${1}" ${_ent_DEBUG})
	else							echo "${_ent_DEBUG}"
	fi
	return 0
}
declare -fx 'debug.set'


#X Function: strict.set is.strict
#X Desc    : Sets/unsets options errexit, nounset and pipefail to
#X         : enable a 'strict' enviroment. Default is off. 
#X         : Use of strict.set on (-o errexit -o nounset -o pipefile)
#X         : is particuarly recommended for development.
#X         : Without parameters, strict.set echos current status (0|1).
#X Synopsis: strict.set [[on|1] | [off|0*]]
#X Example : strict.set on
#X         : curstatus=$(strict.set)
declare -ix _ent_STRICT=0
is.strict() { return $(( ! _ent_STRICT )); }
declare -fx 'is.strict'
	alias strict='is.strict'
	
strict.set() {
	if (( $# )); then
	 	local opt='+'
		_ent_STRICT=$(onoff "${1}" ${_ent_STRICT})
		((_ent_STRICT)) && opt='-'
		set ${opt}o errexit ${opt}o nounset ${opt}o pipefail #${opt}o noclobber
	else
		echo -n "${_ent_STRICT}"
	fi
	return 0
}
declare -fx 'strict.set'

#X Function : msg
#X Desc     : if verbose.set is enabled, send strings to output.
#X          : embedded chars (\n \t etc) enabled by default.
#X          : Tabs and prefixes (if set) are printed with the string.
#X Synopsis : msg [-n] "str" [[-n] "str" ...]
#X          :   -n   suppress line feed, applied separately to each 
#X          :        string argument
#X Example  : msg "hello world!" "it's so nice to be back!"
msg() { ((_ent_VERBOSE)) && _printmsg "$@"; }
declare -fx 'msg'

msg.debug() {
	((_ent_DEBUG)) || return 0
	declare log="${1:-}"
	[[ "${log,,}" == 'log' ]] && shift
	[[ -z "$log" ]] && log=X
	__msgx "$log" 'debug' "${_ent_VERBOSE}" "$@"
	return 0
}
declare -fx 'msg.debug'

# Function : __msgx
# Desc     : output string to terminal with color.
#          : embedded chars (\n \t etc) enabled by default.
# Synopsis : __msgx log msglevel verbose [string ...]
#          : msglevel is one of:
#          :    reset debug info notice warning error
#          :    critical alert emergency
# Example  : __msgx log info 1 "hello world!" "it's so nice to be black!"
__msgx() {
	local log="$1" msglevel="$2" 
	local -i Verbose=$3
	shift 3
	[[ ${log} == 'log' ]] && systemd-cat -t "$PRG" -p "${msglevel}" echo "$@"
	if ((_ent_VERBOSE)) || ((Verbose)); then
		((_ent_COLOR)) && { nc=color$msglevel; echo -ne "${!nc}"; }
			_printmsg "$@"
		((_ent_COLOR)) && echo -ne "${colorreset}"
	fi
	return 0
}
declare -fx '__msgx'

#X Function: msg.info
#X Desc    : Output an informational message, with option to write to log.
#X Synopsis: msg.info [log] "str" ["str" ...]
#X         :   log   If specified, write log entry. 'log' is positional, 
#X				 :         and must appear first.
#X         : If verbose.set is enabled, write to stdout, else return 
#X         : without processing further arguments.
#X         : If color.set is enabled, use color.
#X         : If msg.prefix is set, print prefix before string.
#X         : If tab.set is enabled, print tabs.
#X Example : msg.info "Sir. There's something I think you should know."
#X See Also: msg* verbose.set color.set tab.set prefix.set
msg.info() {
	declare log="${1:-}"
	[[ "${log}" == 'log' ]] && shift
	[[ -z "$log" ]] && log=X
	__msgx "$log" 'info' "${_ent_VERBOSE}" "$@"
	return 0
}
declare -fx 'msg.info'
	alias msginfo='msg.info' #X legacy X#
	alias infomsg='msg.info' #X legacy X#

#X Function: msg.sys
#X Desc    : Output system message, with option to write to log.
#X Synopsis: msg.sys [log] "str" ["str" ...]
#X         :   log   If specified, write syslog entry. 'log' is positional, 
#X				 :         and must appear first.
#X         : If verbose.set is enabled, write to stdout, else return 
#X         : without processing further arguments.
#X         : If color.set is enabled, use color.
#X         : If msg.prefix is set, print prefix before string.
#X         : If tab.set is enabled, print tabs.
#X Example : msg.sys "Sir, I have something to report."
#X See Also: msg* verbose.set color.set tab.set prefix.set
msg.sys() {
	declare log="${1:-}"
	[[ "${log}" == 'log' ]] && shift
	__msgx "$log" "notice" "${_ent_VERBOSE}" "$@"
	return 0
}
declare -fx 'msg.sys'
	alias msgsys='msg.sys' #X legacy X#
	alias sysmsg='msg.sys' #X legacy X#

#X Function: msg.warn
#X Desc    : Output warning message, with option to write to log.
#X Synopsis: msg.warn [log] "str" ["str" ...]
#X         :   log   If specified, write syslog entry. 'log' is positional, 
#X				 :         and must appear first.
#X         : If verbose.set is enabled, write to stdout, else return 
#X         : without processing further arguments.
#X         : If color.set is enabled, use color.
#X         : If msg.prefix is set, print prefix before string.
#X         : If tab.set is enabled, print tabs.
#X Example : msg.warn log "Pardon me, Sir." "Is this supposed to happen?"
#X See Also: msg* verbose.set color.set tab.set prefix.set
msg.warn() {
	declare log="${1:-}"
	[[ ${log} == 'log' ]] && shift || log='X'
	__msgx "$log" 'warning' "${_ent_VERBOSE:-0}" "$@"
	return 0
}
declare -fx 'msg.warn'
	alias msgwarn='msg.warn'	#X legacy X#
	alias warnmsg='msg.warn'	#X legacy X#

#X Function: msg.err
#X Desc    : Output error message to stderr, with option to write to log.
#X Synopsis: msg.err [log] "str" ["str" ...]
#X         :   log   If specified, write syslog entry. 'log' is positional, 
#X				 :         and must appear first.
#X         : If verbose.set is enabled, write to stdout, else return 
#X         : without processing further arguments.
#X         : If color.set is enabled, use color.
#X         : If msg.prefix is set, print prefix before string.
#X         : If tab.set is enabled, print tabs.
#X Example : msg.err log "Sir!" "I think you better come here."
#X See Also: msg* verbose.set color.set tab.set prefix.set
msg.err() {
	declare log="${1:-}"
	[[ ${log} == 'log' ]] && shift
	__msgx >&2 "$log" 'err' '1' "$@"
	return 0
}
declare -fx 'msg.err'

#X Function: msg.die
#X Desc    : Output error message to stderr, with option to write to log,
#X         : and exit with error code.
#X Synopsis: msg.die [log] "str" ["str" ...]
#X         :   log   If specified, write syslog entry. 'log' is positional, 
#X				 :         and must appear first.
#X         : If verbose.set is enabled, write to stdout, else return 
#X         : without processing further arguments.
#X         : If color.set is enabled, use color.
#X         : If msg.prefix is set, print prefix before string.
#X         : If tab.set is enabled, print tabs.
#X Example : msg.die "I'm sorry, Sir." "There's nothing more I can do."
#X See Also: msg* verbose.set color.set tab.set prefix.set
msg.die() {
	declare -i errcode=$?
	declare log="${1:-}"
	[[ ${log} == 'log' ]] && shift
	__msgx >&2 "$log" "crit" "1" "$@"
	exit "$errcode"
}
declare -fx 'msg.die'
	alias msgdie='msg.die'	#X legacy X#
	alias diemsg='msg.die'	#X legacy X#
	alias msgdir='msg.die'	#X for butter fingers #X
	alias msg.dir='msg.die'	#X for butter fingers #X

#X Function : msg.crit
#X Desc    : Output critical error message to stderr, with option to write
#X         : to log, and exit with error code.
#X Synopsis: msg.crit [log] "str" ["str" ...]
#X         :   log   If specified, write syslog entry. 'log' is positional, 
#X				 :         and must appear first.
#X         : If verbose.set is enabled, write to stdout, else return 
#X         : without processing further arguments.
#X         : If color.set is enabled, use color.
#X         : If msg.prefix is set, print prefix before string.
#X         : If tab.set is enabled, print tabs.
#X Example : msg.crit log "Good god!" "Oh, the Humanity..."
#X See Also: msg* verbose.set color.set tab.set prefix.set
msg.crit() {
	declare -i errcode=$?
	declare log="${1:-}"
	[[ "${log}" == 'log' ]] && shift
	__msgx >&2 "$log" "emerg" "1" "$@" 'Call Sysadmin immediately.'
	#mail --to sysadmin@megacorp.dev -s "hello Sir, how are you? are you sitting down?" <<< "Sir, a funny thing just happened."
	exit "$errcode"
}
declare -fx 'msg.crit'
	alias msgcrit='msg.crit' #X legacy X#
	alias critmsg='msg.crit' #X legacy X#

#X Function: msg.line 
#X Desc    : Print a line of replicated characters (default underline) 
#X         : from current cursor position to end of screen.
#X Synopsis: msg.line [repchar [iterations]]
#X         :   repchar     Default repchar is '_'.
#X         :   iterations  Default iterations is number of screen 
#X         :               columns minus 1.
#X         : If verbose.set is disabled, return without processing 
#X         : further arguments.
#X         : If color.set is enabled, use color.
#X         : If msg.prefix is set, print prefix before string.
#X         : If tab.set is enabled, print tabs.
#X Example : msg.line
#X         : msg.line '+'
#X         : msg.line '=' 42
#X See Also: msg* verbose.set color.set tab.set prefix.set
msg.line() {
	((_ent_VERBOSE)) || return 0
	local -i  width=78 screencols=0
	local --  repchar='_'	

	if (( $# )); then
		repchar="${1:0:1}"
		shift
		[[ -n "${1:-}" ]] && screencols=$1
	fi

	if (( ! screencols )); then
		local -- IFS=' ' sx
		local -ai sz
		local -i plen 
		sz=( $(stty size) )
		if (( ${#sz[@]} )); then
			screencols=$(( sz[1] ))
		else
			screencols=$(( COLUMNS ))
		fi
		IFS=$' \t\n'
	fi
	
	sx="${_ent_MSG_PRE[*]}${_ent_MSG_PRE_SEP[*]}" || sx=''
	plen=${#sx}
	width=$(( (screencols - plen - (TABSET * TABWIDTH)) - 2))

  msg "$(head -c $width < /dev/zero | tr '\0' "${repchar:-_}")"

	#msg "$(printf "${repchar}%.0s" $(seq 1 "${width}") )"
	return 0
}
declare -fx 'msg.line'
	alias msgline='msg.line'

#X Function : msg.yn
#X Desc     : Ask y/n question,d return 0/1 
#X Synopsis : msg.yn "str"
#X          : NOTE: if verbose.set is disabled, or there is no tty, msg.yn
#X          : will *always* return 0, without printing the string or waiting 
#X          : for a response.
#X Example  : msg.yn 'Continue?' || msg.die 'Not Continuing.'
msg.yn() {
	((_ent_VERBOSE)) || return 0
	[ -t 0 ] || return 0
	local question="${1:-}" yn=''
	question=$(msg.warn "${question} (y/n)")
	question="${question//$'\n'/ }"
	while true; do
		read -e -n1 -r -p "${question}" yn
		case "${yn,,}" in
			[y]* ) return 0;;
			[n]* ) return 1;;
			* ) echo 'Please answer yes or no.';;
		esac
	done
}
declare -fx 'msg.yn'
	alias askyn='msg.yn' #X legacy X#
	alias ask.yn='msg.yn' #X legacy X#

#X Function : tab.set tab.width
#X Synopsis : tab.set [offset]; tab.width [tabvalue]
#X Desc     :   tab.set    set tab position for output from msg.* functions.
#X          :   tab.width  set tab width (default 4).
#X          : used for formatting output for msg.* and ask.* functions.
#X Synopsis : tab.set [reset | [forward|++] | [backward|--] [indent|+indent|-indent] ]
#X          : no argument causes current tab level to be returned.
#X Example  : tab.width 2; msg.info "tab.width is $(tab.width)"
#X          : tab.set ++; msg.sys "indent 2 columns"
#X          : tab.set reset; msg.warn "indent reset to 0"
#X          : tab.set +3; msg.info "indent to column 6"
#X          : msg "current tab setting is $(tab.set)" 
declare -ix TABWIDTH=4
tab.width() {
	if (( $# )); then
		TABWIDTH=$(( ${1} ))
		((_ent_COLOR)) && tabs "$TABWIDTH"
	else
		echo -n "${TABWIDTH}"
	fi
	return 0
}
declare -fx 'tab.width'

declare -ix TABSET=0
tab.set() {
	if (( $# )); then
		case "${1}" in
			'0'|reset) 		TABSET=0;;
			'++'|forward)	TABSET=$((TABSET+1))			;;
			'--'|back	 	)	TABSET=$((TABSET-1))			;;
			 * 					)	if [[ "${1:0:1}" == '+' ]]; then
											TABSET=$(( TABSET + ${1:1} ))
										elif [[ "${1:0:1}" == '-' ]]; then
											TABSET=$(( TABSET - ${1:1} ))
										else
											TABSET=$(( ${1} ))						
										fi
									;;
		esac
		(( TABSET < 0 )) &&	TABSET=0 # please, curb your enthusiasm.
	else
		echo -n "${TABSET}"
	fi
	return 0
}
declare -fx	'tab.set'

#X Function: msg.prefix.separator.set
#X Desc    : Set/Retrieve value of _ent_MSG_PRE_SEP for appending as a separator for msg.prefix.
#X         : Default separator is ': '
#X Synopsis: msg.prefix.separator.set ["separator"]
#X Example : # 0. set a msg prefix with '>' separator
#X         : msg.prefix.separator.set '>'
#X         : msg.prefix.set "$PRG"
#X         : msg 'Hello world.'
#X See Also: msg.prefix.set
declare -x _ent_MSG_PRE_SEP
_ent_MSG_PRE_SEP=': '
msg.prefix.separator.set() {
	if (( $# ));	then 
		_ent_MSG_PRE_SEP="$1" 
	else 
		echo -n "$_ent_MSG_PRE_SEP"
	fi
	return 0
}
declare -fx 'msg.prefix.separator.set'

#X Function: msg.prefix.set
#X Desc    : Set/Retrieve value of _ent_MSG_PRE for prefixing a string 
#X         : before every string output by the msg.* system.
#X Synopsis: msg.prefix.set [-a] "msgprefix"
#X         : -a  makes msgprefix additive to the existing msg prefix.
#X Example : # 0. set a msg prefix
#X         : msg.prefix.set "$PRG"
#X         : # 1. retrieve current msgprefix
#X         : oldprefix=$(msg.prefix.set)
#X         : # 2. set additive msg prefix
#X         : msg.prefix.set -a 'processing'
#X See Also: msg.prefix.separator.set
declare -ax _ent_MSG_PRE
_ent_MSG_PRE=()
msg.prefix.set() {
	if (( $# ));	then 
		local -i add=0 sub=0
		if   [[ $1 == '++' || $1 == '-a' ]]; then	shift; add=1;
		elif [[ $1 == '--' || $1 == '-d' ]]; then shift; sub=1; 
		else
			_ent_MSG_PRE=( "$1" )
			return 0
		fi
		if ((add)); then
			_ent_MSG_PRE+=( "${1:-}" )
		elif ((sub)); then
			if (( ${#_ent_MSG_PRE[@]} )); then
				_ent_MSG_PRE=( ${_ent_MSG_PRE[@]:0:${#_ent_MSG_PRE[@]}-1} )
			else
				_ent_MSG_PRE=('')
			fi
		fi
		return 0
	fi

	if [[ -n ${_ent_MSG_PRE[*]:-} ]]; then
		local p
		p=${_ent_MSG_PRE[*]}
    echo -n "${p//[[:blank:]]/${_ent_MSG_PRE_SEP}}${_ent_MSG_PRE_SEP}"
	else
		echo -n ''
	fi
	return 0
}
declare -fx 'msg.prefix.set'

_printmsg() {
	local line IFS=$'\t\n' lf=''
	for line in "$@"; do
		[[ ${line} == '-n' ]] && { lf='-n'; continue; }
		if (( ${#_ent_MSG_PRE[*]} )); then
			p=${_ent_MSG_PRE[*]}
			echo -n "${p//[[:blank:]]/${_ent_MSG_PRE_SEP}}${_ent_MSG_PRE_SEP}"
		fi
#		"${_ent_MSG_PRE[*]}${_ent_MSG_PRE_SEP}"
		# shellcheck disable=SC2046
		((TABSET)) && printf '\t%.0s' $(seq 1 ${TABSET})
		echo -e $lf "${line}"
		lf=''
	done
	return 0
}
declare -fx	'_printmsg'

#X Function : exit_if_not_root
#X Desc     : If not root user, print failure message and exit script.
#X Synopsis : exit_if_not_root
exit_if_not_root() {
	is.root || msg.die "$PRG can only be executed by root user."
	return 0
}
declare -fx 'exit_if_not_root'

#X Function : entities.help 
#X Desc     : display help info about Entities functions and variables.
#X Synopsis : entities.help [function|globalvar|localvar|file] | [-s|--search searchstring] [-h|--help]
#X Example  : entities.help msg.yn msg.info
entities.help() {
	"${ENTITIES:-/lib/include/entities}/entities.help" "$@" || return $?
	return 0
}
declare -fx 'entities.help'

#X Function : check.dependencies
#X Desc     : check for script dependencies (programs, scripts, or functions in the environment).
#X Synopsis : check.dependencies [-q|--quiet] name...
#X					:	  -q|--quiet  do not print 'dependency-not-found' messages.
#X          : 	name        is a list of programs, scripts or functions.
#X Example  : (( check.dependencies dirname ln )) && msg.die "Dependencies missing."
#X Depends  : which (not fatal if not found)
check.dependencies() {
	(( ${#@} )) || return 0
	local -- needed_dep=''
	local -- missing_deps=''
	local -i missing=0
	if [[ "${1:-}" == '--quiet' || "${1:-}" == '-q' ]]; then
		local -i _ent_VERBOSE=0 
		shift
	fi
	for needed_dep in "${@}"; do
		if [[ ! -x "$needed_dep" ]]; then
			if [[ ! -x $(which "$needed_dep") ]]; then
				if ! declare -Fp "$needed_dep" >/dev/null 2>&1; then
					if ! hash "$needed_dep" >/dev/null 2>&1; then
						((missing++))
						missing_deps+="$needed_dep "
					fi
				fi
			fi
		fi
	done
	((missing && _ent_VERBOSE)) && \
			echo >&2 "These dependencies are missing: ${missing_deps}"
	return $missing
}
declare -fx 'check.dependencies'


#X Function: trap.breakp
#X Synopsis: trap.breakp [msg]
#X Desc    : prompt to exit script or continue.
trap.breakp() { 
	local b='' prompt=${1:-}
	(( ${#prompt} )) && prompt=" $prompt"
	read -r -e -n1 -p "breakpoint${prompt}: continue? y/n " b
	[[ "${b,,}" == 'y' ]] || exit 1
	return 0
}
declare -fx 'trap.breakp'
	alias breakp='trap.breakp'

#--_ent_MINIMAL if defined, don't do this section.
if (( ! ${_ent_MINIMAL:-0} )); then
#X File: Modules 
#X Desc: By default, *all* files with a '.bash' extension located in
#X     : $ENTITIES/entities.d/** are automatically included in the 
#X     : entities.bash source file. 
#X     : Symlinks to *.bash files are processed last.
	shopt -s globstar
	if [[ -d "${ENTITIES:-/lib/include/entities}/entities.d" ]]; then
		declare _e
		declare -a _userbash=()
		for _e in ${ENTITIES:-/lib/include/entities}/entities.d/**/*.bash; do
			if [[ -r "$_e" ]]; then
				if [[ ! -L "$_e" ]] ; then
					_userbash+=( "${_e}" )
				else
					source "$_e" || echo >&2 "**Source file [$_e] could not be included!" && true
				fi
			fi
		done
		# do symlinks last (includes entities.d/user/*)
		for _e in "${_userbash[@]}"; do
			source "$_e" || echo >&2 "**Source file [$_e] could not be included!" && true
		done
		unset _e _userbash
	fi
	
	#--check dependencies if not minimal
	if ! check.dependencies \
			basename dirname readlink mkdir ln cat \
			systemd-cat stty wget base64 seq tty find touch tree lynx; then
		echo >&2 'Warning: Dependencies not found. entities.bash may not run correctly.'	
	fi 
fi
#^^_ent_MINIMAL

#X Global  : _ent_LOADED
#X Desc    : Integer flag to announce that entities.bash has been loaded. 
#X Defaults: 0
declare -xig _ent_LOADED=1
	declare -xng __entities__='_ent_LOADED' 	 #X legacy X#
# expand all the aliases defined above.
shopt -s expand_aliases # Enables alias expansion.

#-Function Declarations End --------------------------------------------------

_ent_scriptstatus+='[entities loaded]'
#fin
