#!/bin/bash
# *global* !shellcheck 'disables' used by 'p' editor
#! shellcheck disable=SC1090

# Entities.bash - Bash programming environment and library
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
#X Desc   : Entities Functions/Globals Declarations and Initialisations.
#X        : entities.bash is a light-weight Bash function library for systems
#X        : programmers and administrators.
#X        : 
#X        :   _ent_0       $PRGDIR/$PRG
#X        :   PRG          basename of current script. 
#X        :   PRGDIR       directory location of current script, with 
#X        :                symlinks resolved to actual location.
#X        :   _ent_LOADED  is set if entities.bash has been successfully 
#X        :                loaded.
#X        : 
#X        : PRG/PRGDIR are *always* initialised as local vars regardless of 
#X        : 'inherit' status when loading entities.bash.
#X        : 
#X Depends: basename dirname readlink mkdir ln cat stty

#X Global  : _ent_0 PRGDIR PRG
#X Desc    : [_ent_0], [PRGDIR] and [PRG] are global variables that are 
#X         : initialised every time entities.bash is sourced.
#X         : 
#X         :   _ent_0   is the fully-qualified path of the calling program. 
#X         :   PRGDIR   is the directory location of the calling program.
#X         :   PRG      is the basename of the calling program.
#X         : 
#X         : PRG is most often used to identify a running script. 
#X         : PRGDIR is used to identify the directory location of the 
#X         : running script, which often comes in handy.
#X         :
#X Examples: 0. source entities.bash 
#X         :    # If entities.bash has already been loaded, 
#X         :    # then only _ent_0, PRGDIR and PRG globals are initialised.
#X         :    # If entities.bash has not been loaded, then a full load/reload
#X         :    # of all functions and global variables is done also.
#X         : 
#X         : 1. source entities.bash new 
#X         :    # ^ load new instance of entities.bash; 
#X         :    # do not use any existing instance already loaded.
declare -- _ent_0 PRG PRGDIR
declare -x _ent_scriptstatus="[\$0=$0]"

	# Is entities.bash being executed as a script?
	if ((SHLVL > 1)) || [[ ! $0 == ?'bash' ]]; then
		_ent_0="$(/bin/readlink -fn -- "$0")" || _ent_0=''
		_ent_scriptstatus+="[is.script][\$_ent_0=${_ent_0}]"
		# Has entities.bash been executed?
		if [[ "$(/bin/readlink -fn -- "${BASH_SOURCE[0]:-}")" == "$_ent_0" ]]; then
			_ent_scriptstatus+='[execute]'
			declare -ix _ent_LOADED=0
			# do options for execute mode
			while (($#)); do
				case "$1" in
					help)	
							exec "${ENTITIES:-/lib/include/entities}/entities.help" "${@:2}"
							exit $?
							break;;
					-h|--help)	
							source "${ENTITIES:-/lib/include/entities}/e.d/entities.version.bash"
							cat <<-etx
								Program : entities.bash
								Version : ${_ent_VERSION:- Entities.bash version not found. Check installation.}
								Synopsis: 0. entities.bash [help] [-V|--version] [-h|--help] 
								        : 1. source entities.bash [new] 
							etx
							exit 0;;
					-V|--version)
							source "${ENTITIES:-/lib/include/entities}/e.d/entities.version.bash"
							echo "$_ent_VERSION"
							exit ;;	
					# All other passed parameters return error.
					-*)	echo >&2 "$(basename "$0"): Bad option [$1]";		exit 22;;
					*)	echo >&2 "$(basename "$0"): Bad argument [$1]";	exit 22;;
				esac
				shift
			done		
			exit $?
		fi
		_ent_scriptstatus+='[sourced-from-script][SHLVL='"$SHLVL"']'
		PRG=$(/usr/bin/basename "$_ent_0")
		PRGDIR=$(/usr/bin/dirname "$_ent_0")
		_ent_scriptstatus+="[PRGDIR=$PRGDIR]"

		# `entities` is already loaded, and no other parameters have 
		# been given, so do not reload.
		if (( ! $# )); then
			(( ${_ent_LOADED:-0} )) && return 0
		fi
	
	else
		# [source entities] has been executed at the shell command prompt
		_ent_scriptstatus+='[sourced-from-shell][SHLVL='"$SHLVL"']'
		_ent_0=$(/bin/readlink -fn -- "${BASH_SOURCE[0]}") || _ent_0=''
		PRG=$(/usr/bin/basename "$_ent_0")
		PRGDIR=$(/usr/bin/dirname "$_ent_0")
		_ent_scriptstatus+="[PRGDIR=$PRGDIR]"
		if [[ -n "${ENTITIES:-}" ]]; then
			PATH="${PATH//\:${ENTITIES}/}"
			PATH="${PATH//\:\:/\:}"
		fi
		export ENTITIES="$PRGDIR"
		export PATH="${PATH}:${ENTITIES}"		
		declare -ix _ent_LOADED=0		# always reload when sourced from command line
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
#X         : already been loaded or not. If it has, then it exits 
#X         : immediately without re-initialising entities functions.
#X Example : (( ${_ent_LOADED:-0} )) \
#X         :     || { echo >&2 'entities.bash not loaded!'; exit; }
(( ${_ent_LOADED:-0} )) && return 0;
declare -ix _ent_LOADED=0

_ent_scriptstatus+='[reloading]'

# turn off 'strict' by default
set +o errexit +o nounset +o pipefail

# oh why not ... (please, tell me why not.)
shopt -s extglob
shopt -s globstar

# msgx ########################################################################
#X Function: msgx msg msg.die msg.emerg msg.alert msg.crit msg.err msg.warning msg.notice msg.info msg.debug msg.sys 
#X Desc    : Console message functions.  msg() functions support verbose, 
#X         : message prefixes, tabs and color. 
#X         : If msg.verbose.set is enabled, send strings to output.
#X         : embedded chars (\n \t etc) enabled by default.
#X         : Tabs and prefixes (if set) are printed with the string.
#X         :
#X Synopsis: msg.* [--log] [--notag] [--raw] [--errno num] "str" ["str" ...]
#X         :   msg           Print to stdout with no color or stdio tag.
#X         :   msg.die       Print die message to stderr and exit.
#X         :   msg.emerg     Print emergency message to stderr and exit.
#X         :   msg.alert     Print alert message to stderr and and exit.
#X         :   msg.crit      Print critical message to stderr and exit.  
#X         :   msg.err       Print error message to stderr.
#X         :   msg.warning   Print warning message to stderr.
#X         :   msg.notice    Print notice message to stdout.
#X         :   msg.info      Print notice message to stdout.
#X         :   msg.debug     Print debug message to stderr.
#X         :   msg.sys       Print system message to stderr and log
#X         :                 message using stdio code.
#X         :   -e|--errno n  Set error return/exit code to n.
#X         :   -l|--log      Log message to syslog.
#X         :   -n|--raw      Print without tabs, prefixes or linefeeds.
#X         :   -t|--notag    Do not print stdio tag (eg, info, err, sys).
#X         :
#X Example : msg "hello world!" "it's so nice to be back!"
#X         : msg.sys "Sir, I have something to log."
#X         : msg.info "Sir. There's something you need to know."
#X         : msg.warn --log "Pardon me, Sir." "Is this supposed to happen?"
#X         : msg.err --log "Sir!" "I think you better come here."
#X         : msg.die --log --errno 22 "Sir!" "This isn't supposed to happen."
#X         : # Results:
#X         :  [0;39;49mhello world!
#X         :  [0;39;49m[0;39;49mit's so nice to be back!
#X         :  [0;39;49msys: Sir, I have something to log.
#X         :  [0;39;49m[32minfo: Sir. There's something you need to know.
#X         :  [0;39;49m[33mwarning: Pardon me, Sir.
#X         :  [0;39;49m[33mwarning: Is this supposed to happen?
#X         :  [0;39;49m[31merr: Sir!
#X         :  [0;39;49m[31merr: I think you better come here.
#X         :  [0;39;49mdie: Sir!
#X         :  [0;39;49mdie: This isn't supposed to happen.
#X         :  [0;39;49m
#X See Also: msg.verbose.set msg.color.set msg.prefix.set msg.tab.set
# shellcheck disable=SC2034,2016
declare -x \
	io_='stdio="";' 								\
	io_die='std=2;die=1;errno=1;' 	\
	io_emerg='std=2;die=1;errno=1;' \
	io_alert='std=2;die=1;errno=1;' \
	io_crit='std=2;die=1;errno=1;' 	\
	io_err='std=2;' 								\
	io_warning='std=2;' 						\
	io_notice='std=1;' 							\
	io_info='std=1;' 								\
	io_debug='std=2;' 							\
	io_sys='std=2;log=1;' 

msgx() { 
	(( ! _ent_VERBOSE )) && return 0
	local -i std=1 die=0 log=0 raw=0 errno=0 tag=1
	local stdio='' sx

	if (($#)) && [[ ${1:0:2} == '--' ]]; then
		#((_ent_DEBUG)) && echo "$@"
		stdio="${1:2:8}"
		#stdio="${stdio//-/}"; stdio="${stdio// /}"
		#((_ent_DEBUG)) && echo "sx=[$sx] stdio=[$stdio] $std $die $errno $log"
		sx="io_$stdio"
		if [[ -v "$sx" ]]; then
			shift
			eval "${!sx}"
		else
			stdio=''
			#((_ent_DEBUG)) && echo "sx=[$sx]"
		fi
	fi
	
	while (($#)); do
		# these are all front-facing options; the first non-option signals 
		# that rest of args are all printed with these settings.
		case $1 in
			-t|--notag)		tag=0;;
			-n|--raw)			raw=1;;
			-e|--errno)		std=2; shift; errno=$((${1:-0}));;
			-l|--log|log)	log=1;;
			*)						break;;
		esac
		shift
	done	
#	((tag)) && ((_ent_MSG_USE_TAG)) && [[ -n $stdio ]] && msg.prefix.set ++ "$stdio"
	((tag)) && ((_ent_MSG_USE_TAG)) && [[ -n $stdio ]] && _ent_MSG_PRE+=( "$stdio" )
	
	while (($#)); do
		if ((raw)); then
			((_ent_COLOR)) && { nc=color$stdio; echo -ne "${!nc}"; }
			echo >&${std} -en "$1"
			((_ent_COLOR)) && echo -ne "$colorreset"
		else
			((_ent_COLOR)) && { nc=color$stdio; echo -ne "${!nc}"; }
			if (( ${#_ent_MSG_PRE[*]} )); then
				p=${_ent_MSG_PRE[*]}
				echo -n "${p//[[:blank:]]/${_ent_MSG_PRE_SEP}}${_ent_MSG_PRE_SEP}"
			fi
			((_ent_TABSET)) && printf '\t%.0s' $(seq 1 "$_ent_TABSET")
			echo >&${std} -e "$1"
			((_ent_COLOR)) && echo -ne "$colorreset"
		fi
		if ((log)); then
			sx=${stdio:-err}
			[[ $sx == 'sys' || $sx == 'die'  ]] && sx='err'
			systemd-cat -t "${_ent_MSG_PRE[*]}" -p "$sx" echo "$( ((errno)) && echo "$errno: ")$1"
		fi
		shift
	done
	
	# shellcheck disable=SC2162
	if read -t 0; then 
		while read -sr line; do 
			((_ent_COLOR)) && { nc=color$stdio; echo -ne "${!nc}"; }
			if (( ${#_ent_MSG_PRE[*]} )); then
				p=${_ent_MSG_PRE[*]}
				echo -n "${p//[[:blank:]]/${_ent_MSG_PRE_SEP}}${_ent_MSG_PRE_SEP}"
			fi
			((_ent_TABSET)) && printf '\t%.0s' $(seq 1 "$_ent_TABSET")
			echo >&${std} "$line"
			((_ent_COLOR)) && echo -ne "$colorreset"
			if ((log)); then
				sx=${stdio:-err}
				[[ $sx == 'sys' || $sx == 'die'  ]] && sx='err'
				systemd-cat -t "${_ent_MSG_PRE[*]}" -p "$sx" echo "$( ((errno)) && echo "$errno: ")$line"
			fi
		done
	fi

	((tag)) && ((_ent_MSG_USE_TAG)) && [[ -n $stdio ]] && msg.prefix.set '--'

	((die)) && exit "$errno"
	return 0
}
declare -fx 'msgx'
msg()					{ msgx "$@"; }
msg.die() 		{ msgx --die "$@"; }
msg.emerg() 	{ msgx --emerg "$@"; }
msg.alert() 	{ msgx --alert "$@"; }
msg.crit()	 	{ msgx --crit "$@"; }
msg.err() 		{ msgx --err "$@"; }
msg.error()		{ msgx --err "$@"; } #X legacy X#
msg.warning() { msgx --warning "$@"; }
msg.warn() 		{ msgx --warning "$@"; }  #X legacy X#
msg.notice() 	{ msgx --notice "$@"; }
msg.info() 		{ msgx --info "$@"; }
msg.debug() 	{ msgx --debug "$@"; }
msg.sys() 		{ msgx --sys "$@"; }
declare -fx 'msg' 'msg.die' 'msg.emerg' 'msg.alert' 'msg.crit' 'msg.err' 'msg.warning' 'msg.warn' 'msg.notice' 'msg.info' 'msg.debug' 'msg.sys'

#X Global  : _PATH_LOG LOG_EMERG LOG_ALERT LOG_CRIT LOG_ERR LOG_WARNING LOG_NOTICE LOG_INFO LOG_DEBUG LOG_PRIORITYNAMES 
#X Desc    : Global Exported Read-Only constants from [syslog.h].
#X         :  _PATH_LOG='/dev/log'
#X         : 	# priorities (these are ordered)
#X         :	LOG_EMERG=0		# system is unusable 
#X         : 	LOG_ALERT=1		# action must be taken immediately 
#X         : 	LOG_CRIT=2		# critical conditions 
#X         : 	LOG_ERR=3			# error conditions 
#X         : 	LOG_WARNING=4	# warning conditions 
#X         : 	LOG_NOTICE=5	# normal but significant condition 
#X         : 	LOG_INFO=6		# informational 
#X         : 	LOG_DEBUG=7		# debug-level messages 
#X         : 	LOG_PRIORITYNAMES='emerg alert crit err warning notice info debug'
#X See Also: msg*
# read-only vars can only be declared once.
if (( ! ${LOG_ALERT:-0} )); then
	declare -xr		_PATH_LOG='/dev/log'
	# priorities (these are ordered)
	declare -ixr	LOG_EMERG=0		# system is unusable 
	declare -ixr	LOG_ALERT=1		# action must be taken immediately 
	declare -ixr	LOG_CRIT=2		# critical conditions 
	declare -ixr	LOG_ERR=3			# error conditions 
	declare -ixr	LOG_WARNING=4	# warning conditions 
	declare -ixr	LOG_NOTICE=5	# normal but significant condition 
	declare -ixr	LOG_INFO=6		# informational 
	declare -ixr	LOG_DEBUG=7		# debug-level messages 
	declare -xr		LOG_PRIORITYNAMES='emerg alert crit err warning notice info debug'
fi

#X Global  : CR CH9 LF OLDIFS IFS
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
	local o=${1:-0}
	case "${o,,}" in
		on|1)			o=1;;
		off|0)		o=0;;
		*)				o=$(( ${2:-0} ));; 
	esac
	echo -n $((o))
	return 0
}
declare -fx 'onoff'

#X Function: msg.verbose.set msg.verbose
#X Desc    : Set global verbose status for msg* functions. For shell 
#X         : terminal verbose is ON by default, otherwise, when called 
#X         : from another script, verbose is OFF by default.
#X         : msg.verbose.set status is used in the msg.yn and some msg.* 
#X         : commands, except msg.sys, msg.die and msg.crit, which will 
#X         : always ignore verbose status and output to STDERR.
#X         : 
#X Synopsis: msg.verbose.set [on|1] | [off|0]
#X         : curstatus=$(msg.verbose.set)      
#X         : msg.verbose returns true if verbose is set, false if not.
#X         : 
#X Example : oldverbose=$(msg.verbose.set)
#X         : msg.verbose.set on
#X         : # do stuff... #
#X         : msg.verbose.set $oldverbose
#X         : msg.verbose && echo "Verbose is on."
#X         : _ent_VERBOSE controls output from msg*() functions.
declare -ix _ent_VERBOSE
[ -t 1 ] && _ent_VERBOSE=1 || _ent_VERBOSE=0
msg.verbose() { return $(( ! _ent_VERBOSE )); }
declare -fx 'msg.verbose'
#	verbose() { msg.verbose "$@"; }; 		declare -fx verbose 
	is.verbose() { msg.verbose "$@"; };	declare -fx 'is.verbose' #X legacy X#

msg.verbose.set() {
	if (( ${#@} )); then
		_ent_VERBOSE=$(onoff "$1")
	else
		echo -n "$_ent_VERBOSE"
	fi
#	return 0
}
declare -fx 'msg.verbose.set'
	verbose.set() { msg.verbose.set "$@"; }; declare -fx 'verbose.set' #X legacy X#
	
declare -ix '_ent_MSG_USE_TAG'
_ent_MSG_USE_TAG=1
msg.usetag.set() {
	if (( ${#@} )); then
		_ent_MSG_USE_TAG=$(onoff "$1")
	else
		# shellcheck disable=SC2086
		echo -n $_ent_MSG_USE_TAG
	fi
#	return 0
}
declare -fx 'msg.usetag.set'
	
#X Global  : colorreset colordebug colorinfo colornotice colorwarning colorerr colorcrit coloralert coloremerg
#X Desc    : Colors used by entities msg.* functions.
#X         : emerg alert crit err warning notice info debug
#X         : panic (dep=emerg) err (dep=error) warning (dep=warn)
#X See Also:
declare -x colorreset="\x1b[0;39;49m"
declare -x color="\x1b[0;39;49m"
declare -x color0="\x1b[0;39;49m"
declare -x colordebug="\x1b[35m"
declare -x colorinfo="\x1b[32m"
declare -x colornotice="\x1b[34m"
declare -x colorwarning="\x1b[33m";					declare -nx colorwarn='colorwarning'
declare -x colorerr="\x1b[31m";							declare -nx colorerror='colorerr'
declare -x colorcrit="\x1b[1;31m";					declare -nx colorcritical='colorcrit'
declare -x coloralert="\x1b[1;33;41m"
declare -x coloremerg="\x1b[1;4;5;33;41m";	declare -nx colorpanic='coloremerg'

#X Function: msg.color.set msg.color
#X Desc    : Turn on/off colorized output from msg.* functions.
#X         : 
#X Synopsis: msg.color.set [ON|1][OFF|0][auto]
#X         : curstatus=$(msg.color.set)
#X Example : 
#X         : oldstatus=$(msg.color.set)
#X         : msg.color.set off
#X         : # do stuff... #
#X         : msg.color.set $oldstatus
declare -ix '_ent_COLOR'
_ent_COLOR=1
[ -t 1 ] && _ent_COLOR=1 || _ent_COLOR=0
msg.color() { return $(( ! _ent_COLOR )); }
declare -fx 'msg.color'
	color() { 'msg.color' "$@"; }; declare -fx 'color' #X legacy X#
	is.color() { 'msg.color' "$@"; };	declare -fx 'is.color' #X legacy X#
	
msg.color.set() {
	if (( ${#@} )); then 
		if [[ $1 == 'auto' ]]; then
			[ -t 1 ] && status=1 || status=0
		else
			status=$1
		fi
		_ent_COLOR=$(onoff "$status" "$_ent_COLOR")
	else 
		echo -n "$_ent_COLOR"
	fi
#	return 0
}
declare -fx 'msg.color.set'
	color.set() { 'msg.color.set' "$@"; };	declare -fx 'color.set' #X legacy X#

#X Function : msg.tab.set msg.tab.width
#X Synopsis : msg.tab.set [offset]; msg.tab.width [tabvalue]
#X Desc     :   msg.tab.set    set tab position for output from msg.* functions.
#X          :   msg.tab.width  set tab width (default 4).
#X          : used for formatting output for msg.* and ask.* functions.
#X          : 
#X Synopsis : msg.tab.set [reset | [forward|++] | [backward|--] [indent|+indent|-indent] ]
#X          : no argument causes current tab level to be returned.
#X          : 
#X Example  : msg.tab.width 2; msg.info "msg.tab.width is $(msg.tab.width)"
#X          : msg.tab.set ++; msg.sys "indent 2 columns"
#X          : msg.tab.set reset; msg.warn "indent reset to 0"
#X          : msg.tab.set +3; msg.info "indent to column 6"
#X          : msg "current tab setting is $(msg.tab.set)" 
declare -ix '_ent_TABWIDTH'
_ent_TABWIDTH=4
msg.tab.width() {
	if (( $# )); then
		_ent_TABWIDTH=$(( $1 ))
		((_ent_COLOR)) && tabs $_ent_TABWIDTH
	else
		echo -n $_ent_TABWIDTH
	fi
	return 0
}
declare -fx 'msg.tab.width'
	tab.width() { 'msg.tab.width' "$@"; }; declare -fx 'tab.width' #X legacy X#

declare -ix '_ent_TABSET'
_ent_TABSET=0
msg.tab.set() {
	if (( $# )); then
		case "$1" in
			0|reset)	_ent_TABSET=0;;
			++)				_ent_TABSET=$((_ent_TABSET+1))			;;
			--)				_ent_TABSET=$((_ent_TABSET-1))			;;
			 *)				if [[ "${1:0:1}" == '+' ]]; then
									_ent_TABSET=$(( _ent_TABSET + ${1:1} ))
								elif [[ "${1:0:1}" == '-' ]]; then
									_ent_TABSET=$(( _ent_TABSET - ${1:1} ))
								else
									_ent_TABSET=$(( $1 ))						
								fi
								;;
		esac
		(( _ent_TABSET < 0 )) &&	_ent_TABSET=0 # please, curb your enthusiasm.
	else
		echo -n $_ent_TABSET
	fi
	return 0
}
declare -fx	'msg.tab.set'
	tab.set() { 'msg.tab.set' "$@"; }; declare -fx 'tab.set' #X legacy X#
	
#X Function: msg.prefix.separator.set
#X Desc    : Set/Retrieve value of _ent_MSG_PRE_SEP for appending as a separator for msg.prefix.
#X         : Default separator is ': '
#X Synopsis: msg.prefix.separator.set ["separator"]
#X         : 
#X Example : # 0. set a msg prefix with '>' separator
#X         : msg.prefix.separator.set '>'
#X         : msg.prefix.set "$PRG"
#X         : msg 'Hello world.'
#X See Also: msg.prefix.set
declare -x '_ent_MSG_PRE_SEP'
_ent_MSG_PRE_SEP=': '
msg.prefix.separator.set() {
	if (( $# ));	then 
		_ent_MSG_PRE_SEP="$1" 
	else 
		echo -n "$_ent_MSG_PRE_SEP"
	fi
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
declare -ax '_ent_MSG_PRE'
_ent_MSG_PRE=()
msg.prefix.set() {
	if (( $# ));	then 
		local -i add=0 sub=0
		if [[ $1 == '++' ]]; then
			shift; add=1
		elif [[ $1 == '--' ]]; then
			shift; sub=1 
		else
			_ent_MSG_PRE=( "$1" )
			return 0
		fi
		if ((add)); then
			_ent_MSG_PRE+=( "${1:-}" )
		elif ((sub)); then
			if (( ${#_ent_MSG_PRE[@]} > 1 )); then
				# shellcheck disable=SC2206
				_ent_MSG_PRE=( ${_ent_MSG_PRE[@]:0:${#_ent_MSG_PRE[@]}-1} )
			else
				_ent_MSG_PRE=()
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

#X Function: msg.line 
#X Desc    : Print a line of replicated characters (default underline) 
#X         : from current cursor position to end of screen.
#X Synopsis: msg.line [repchar [iterations]]
#X         :   repchar     Default repchar is '_'.
#X         :   iterations  Default iterations is number of screen 
#X         :               columns minus 1.
#X         : If msg.verbose.set is disabled, return without processing 
#X         : further arguments.
#X         : If msg.color.set is enabled, use color.
#X         : If msg.prefix is set, print prefix before string.
#X         : If msg.tab.set is enabled, print tabs.
#X Example : msg.line
#X         : msg.line '+'
#X         : msg.line '=' 42
#X See Also: msg* msg.verbose.set msg.color.set msg.tab.set msg.prefix.set
msg.line() {
	((_ent_VERBOSE)) || return 0
	local -i  width=78 screencols=0 plen
	local --  repchar='_'	sx

	if (( $# )); then
		repchar="${1:0:1}"
		shift
		[[ -n "${1:-}" ]] && screencols=$1
	fi

	if (( ! screencols )); then
		local -- IFS=' ' sx
		local -ai sz
		mapfile -d' ' -t sz < <(stty size)
		if (( ${#sz[@]} )); then
			screencols=$(( sz[1] ))
		else
			screencols=$(( ${COLUMNS:-78} ))
		fi
		IFS=$' \t\n'
	fi
	
	sx="${_ent_MSG_PRE[*]}${_ent_MSG_PRE_SEP[*]}" || sx=''
	plen=$(( ${#sx} + ${#_ent_MSG_PRE[@]} ))
	((plen)) || plen=1
	width=$(( (screencols - plen - (_ent_TABSET * _ent_TABWIDTH)) ))

  msg "$(head -c $width < /dev/zero | tr '\0' "${repchar:-_}")"

	#msg "$(printf "${repchar}%.0s" $(seq 1 "${width}") )"
	return 0
}
declare -fx 'msg.line'
	msgline() { 'msg.line' "$@"; }; declare -fx 'msgline' #X legacy X#

#X Function : msg.yn
#X Desc     : Ask y/n question,d return 0/1 
#X Synopsis : msg.yn [--warning|--err|--info|--notice|--debug] "str"
#X          : NOTE: If msg.verbose.set is off (disabled), or there is no tty, 
#X          : msg.yn will *always* return 0, without printing the string or 
#X          : waiting for a response.
#X Example  : msg.yn 'Continue?' || msg.die 'Not Continuing.'
msg.yn() {
	((_ent_VERBOSE)) || return 0
	[ -t 0 ] || return 0
	local stdio=''
	if (($#)); then
		if [[ ${1:0:2} == '--' ]]; then
			stdio="$1"
			shift
		fi
	fi
	local question="${1:-}" yn=''
	# shellcheck disable=SC2086
	question=$(msgx $stdio --notag "$question (y/n)" 2>&1 )
	question="${question//$'\n'/ }"
	while true; do
		read -e -r -p "$question" yn
		case "${yn,,}" in
			[y]* ) return 0;;
			[n]* ) return 1;;
			* ) msg.err 'Answer [y]es or [n]o.';;
		esac
	done
}
declare -fx 'msg.yn'

#X Function : version.set
#X Desc     : Set or return version number of the current script.
#X Defaults : '0.0.0'
#X Synopsis : version.set "verstring"
#X          : $(version.set)
#X Example  : version.set '4.20'	# set script version.
#X          : version.set					# print current script version.
#X          : ver=$(version.set)	# store current version setting to variable.
declare -x '_ent_SCRIPT_VERSION'
_ent_SCRIPT_VERSION='0.0.0'
version() { echo -n "$_ent_SCRIPT_VERSION"; return 0; }
declare -fx 'version'
version.set() {
	if (( ${#@} )); then _ent_SCRIPT_VERSION="$1"
								else echo -n "$_ent_SCRIPT_VERSION"
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
declare -ix '_ent_DRYRUN'
_ent_DRYRUN=0
is.dryrun() { return $(( ! _ent_DRYRUN )); }
declare -fx 'is.dryrun'
	dryrun() { 'is.dryrun' "$@"; }; declare -fx 'dryrun' #X legacy X#

dryrun.set() {
	if (( $# )); then 
		_ent_DRYRUN=$(onoff "$1" "$_ent_DRYRUN")
	else 
		#	-- SC2086: Double quote to prevent globbing and word splitting.
		# shellcheck disable=SC2086
		echo -n $_ent_DRYRUN
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
declare -ix '_ent_DEBUG'
_ent_DEBUG=0
is.debug() {	return $(( ! _ent_DEBUG )); }
declare -fx 'is.debug'
	debug() { is.debug "$@"; }; declare -fx 'debug' #X legacy X#
	
debug.set() {
	if (( $# )); then _ent_DEBUG=$(onoff "$1" $_ent_DEBUG)
	else							echo "$_ent_DEBUG"
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
declare -ix '_ent_STRICT'
_ent_STRICT=0
is.strict() { return $(( ! _ent_STRICT )); }
declare -fx 'is.strict'
	
strict.set() {
	if (( $# )); then
	 	local opt='+'
		_ent_STRICT=$(onoff "$1" $_ent_STRICT)
		((_ent_STRICT)) && opt='-'
		set ${opt}o errexit ${opt}o nounset ${opt}o pipefail #${opt}o noclobber
	else
		echo -n "$_ent_STRICT"
	fi
	return 0
}
declare -fx 'strict.set'


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
#X Synopsis : entities.help [about|function|globalvar|file] [filename] [action]
#X          : entities.help [-s|--search searchstring] [-h|--help]
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
	for needed_dep in "$@"; do
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
	return "$missing"
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
	breakp() { 'trap.breakp' "$@"; }; declare -fx 'breakp' #X legacy X#

#--_ent_MINIMAL if defined, don't do this section.
if (( ! ${_ent_MINIMAL:-0} )); then
#X File: Modules 
#X Desc: By default, *all* files with a '.bash' extension located in
#X     : $ENTITIES/e.d/** are automatically included in the 
#X     : entities.bash source file. 
#X     : Symlinks to *.bash files are processed last.
	shopt -s globstar
	if [[ -d "${ENTITIES:-/lib/include/entities}/e.d" ]]; then
		declare '_e'
		declare -a _userbash=()
		for _e in "${ENTITIES:-/lib/include/entities}"/e.d/**/*.bash; do
			if [[ -r "$_e" ]]; then
				if [[ ! -L "$_e" ]] ; then
					_userbash+=( "$_e" )
				else
					source "$_e" || echo >&2 "**Source file [$_e] could not be included!" && true
				fi
			fi
		done
		# do symlinks last (includes e.d/user/*)
		for _e in "${_userbash[@]}"; do
			source "$_e" || echo >&2 "**Source file [$_e] could not be included!" && true
		done
		unset _e _userbash
	fi
	
	#--check dependencies if not minimal
	if ! check.dependencies \
			basename dirname readlink mkdir ln cat \
			systemd-cat wget base64 seq tty find touch tree lynx; then
		echo >&2 'Warning: Dependencies not found. entities.bash may not run correctly.'	
	fi 
fi
#^^_ent_MINIMAL
#-Function Declarations End --------------------------------------------------

# expand all the aliases defined above.
#shopt -s expand_aliases # Enables alias expansion.

_ent_scriptstatus+="[entities loaded $(date +'%F %T')]"

#X FILE    : entities.bash.startup.conf 
#X Desc    : If it exists, the file [/etc/entities/entities.bash.startup.conf]
#X         : is executed immediately *after* entities.bash has been fully 
#X         : loaded.
#X         : 
#X         : This file should contain server-preferred global defaults for every 
#X         : entities.bash instance on this machine.
#X         : 
#X         : Keep entries simple.
#X See     : /etc/entities/entities.bash.startup.conf
if [[ -f '/etc/entities/entities.bash.startup.conf' ]]; then
	source '/etc/entities/entities.bash.startup.conf'
fi

#X Global  : _ent_LOADED
#X Desc    : Integer flag to announce that entities.bash has been loaded. 
#X         : If not set, or set to 0, then entities.bash is not loaded.
declare -xig '_ent_LOADED'
_ent_LOADED=1
#fin
