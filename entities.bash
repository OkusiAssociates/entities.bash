#!/bin/bash
# shellcheck disable=SC2035
# shellcheck disable=SC2154
# shellcheck disable=SC1090
# shellcheck disable=SC2086

# Bash only
#libfunc1() { ...; }
#libfunc2() { ...; }
#sourced() { [[ ${FUNCNAME[1]} = source ]]; }
#sourced && return

# process command line arguments, etc.
#X Intro    : entities.bash
#X Desc     : Entities Functions/Globals/Local Declarations and Initialisations.
#X          : entities.bash is a light-weight Bash function library for systems
#X          : programmers and administrators.
#X          : __entities__=is set if entities has been successfully loaded.
#X          : PRG=basename of current script. 
#X          : PRGDIR=directory location of current script, with softlinks 
#X          : resolved to actual location.
#X          : PRG/PRGDIR are *always* initialised as local vars regardless of 
#X          : 'inherit' status when loading entities.bash.
#X Depends  : basename dirname readlink mkdir ln cat systemd-cat stty

#X Local    : PRG PRGDIR 
#X Synopsis : source entities.bash [ [inherit*] | [new] | [load libname] 
#X          :                       | [no-load libname] | [load-to newdir] ] 
#X          : source entities.bash inherit 
#X          :       # ^ if entities.bash has already been loaded, 
#X          :       # init PRGDIR/PRG globals only then return.
#X          :       # if entities.bash has not been loaded, load it.
#X          :       # [inherit] is the default. 
#X          : source entities.bash new 
#X          :       # ^ load new instance of entities.bash; 
#X          :       # do not use any existing instance already loaded.
#X          : source entities.bash load libname
#X          :       # ^ load an additional library of bash scripts 
#X          : source entities.bash no-load libname
#X          :       # ^ infers new, libname is not loaded with entities.bash 
#X          : source entities.bash load-to newdir
#X          :       # ^ load into new dir (eg, /run/entities) and
#X          :       # set ENTITIES globalvar to new position. 
declare -- PRG PRGDIR 
declare -x _ent_scriptstatus="\$0=$0|"

	# is script is being run?
	if ((SHLVL > 1)) || [[ ! $0 == ?'bash' ]]; then
		p_="$(/bin/readlink -f "${0}")"
		_ent_scriptstatus+="is.script|\$p_=$p_|\n"
		# has entities.bash been executed?
		if [[ "$(/bin/readlink -f "${BASH_SOURCE[0]:-}")" == "$p_" ]]; then
			_ent_scriptstatus+='is.execute|\n'
			__entities__=0
			while (($#)); do
				# do options for execute
		    case "${1,,}" in
					-h|--help)	entities.help "#@"
											echo 'tbd: entities execute help'
											break ;;
					# all other passed parameters are ignored.
					-*)					echo >&2 "$0: Bad option '$1' in entities.bash!";		exit 1 ;;
					*)					echo >&2 "$0: Bad argument '$1' in entities.bash!";	exit 1 ;;
				esac
				shift
			done		
			exit
		fi
		_ent_scriptstatus+="is.sourced-from-script|SHLVL=$SHLVL|\n"
		PRG="$(/usr/bin/basename "${p_}")"
		PRGDIR="$(/usr/bin/dirname "${p_}")"
		_ent_scriptstatus+="PRGDIR=$PRGDIR|\n"
		unset _p
	  # entities is already loaded, and no other parameters have been given, so do not reload.
		if (( ! $# )); then
			(( ${__entities__:-} )) && return 0
		fi
	
	# source entities has been executed at the shell command prompt
	else
		_ent_scriptstatus+="sourced-from-shell|SHLVL=$SHLVL|\n"
		p_="$(/bin/readlink -f "${BASH_SOURCE[0]}")"
		PRG="$(/usr/bin/basename "${p_}")"
		PRGDIR="$(/usr/bin/dirname "${p_}")"
		_ent_scriptstatus+="PRGDIR=$PRGDIR|\n"
		unset _p
		if [[ -n "${ENTITIES:-}" ]]; then
			PATH="${PATH//\:${ENTITIES}/}"
			PATH="${PATH//\:\:/\:}"
		fi
		export ENTITIES="$PRGDIR"
		export PATH="${PATH}:${ENTITIES}"		
		__entities__=0		# always reload when sourced from command line
	fi

	# there are parameters
	while (($#)); do
		case "${1,,}" in
			# new load
			new) 									__entities__=0 ;;
			# does the calling script wish to inherit the current Entities environment/functions?
			# (inherit is the default)
				# can only inherit if called from a script
			''|inherit|preserve)	__entities__=${__entities__:-0} ;;

			# all other passed parameters are ignored (possibly script parameters? but not for entities)
			*)	break;;
		esac
		shift
	done

#X Global   : __entities__
#X Desc     : __entities__ global indicated whether entities.bash has 
#X          : already been loaded or not.
#X Example  : (("${__entities__:-}")) || { echo >&2 'entities.bash not loaded!'; exit; }
((__entities__)) && return 0;
#echo 'reloading...'
_ent_scriptstatus+="reloading|\n"


# turn off strict while we run through the included functions! (strict is default)
set +o errexit +o nounset +o pipefail

# why not? ...
shopt -s extglob


#X Global   : GlobalCharVars CH9 LF CR OLDIFS IFS
#X Desc     : Constant global char values.
#X          : NOTE: IFS is 'normalised' on every full execution of entities.
#X          :       OLDIFS retains the existing IFS
#X Synopsis : LF=$'\n' CR=$'\r' CH9=$'\t' OLDIFS="$IFS" IFS=$' \t\n' 
#X Defaults : OLDIFS=$IFS     # captures existing IFS before assigning 'standard' IFS
#X          : IFS=$' \\t\\n'  # 'standard' IFS
#X Example  : str = "${LF}${CH9}This is a wrapping string.${LF}{$CH9}This is another sentence."
#X          : echo -e "$str"
declare -x  LF=$'\n' CR=$'\r' CH9=$'\t'
declare -x  OLDIFS="$IFS" IFS=$' \t\n'
declare -nx OIFS="OLDIFS"


#X Function : onoff 
#X Desc     : echo 1 if 'on', 0 if 'off'
#X Synopsis : onoff on|1 || off|0 [defaultval]
#X          : for ambiguous value, echo 'defaultval' if defined, otherwise echo 0.
#X Example  : result=$(onoff off 1)
onoff() {
	local o="${1:-0}"
	case "${o,,}" in
		on|1)			o=1;;
		off|0)		o=0;;
    *)        o=0; (( $# > 1 )) && o=$(( ${2} ));; 
	esac
	echo -n $((o))
	return 0
}
declare -fx onoff


#X Function : verbose.set 
#X Desc     : Set global verbose status. For shell terminal verbose ON by default,
#X          : otherwise, called from another script, verbose is OFF by default.
#X          : verbose.set() status is used in the ask.yn() and some msg.*() 
#X          : commands, except msg.sys(), msg.die() and msg.crit(), which will 
#X          : always ignore verbose status.
#X Synopsis : verbose.set [ON|1] | [OFF|0]
#X          : curstatus=$(verbose.set)      
#X Example  : 
#X          : oldverbose=$(verbose.set)
#X          : verbose.set on
#X          : # do stuff... #
#X          : verbose.set $oldverbose
declare -ix _ent_VERBOSE
[ -t 1 ] && _ent_VERBOSE=1 || _ent_VERBOSE=0
verbose() { return $(( ! _ent_VERBOSE )); }
declare -fx verbose
verbose.set() {   
	if ((${#@})); then
		_ent_VERBOSE=$(onoff "${1}")
	else
		#-- SC2086: Double quote to prevent globbing and word splitting.
		# shellcheck disable=SC2086
		echo -n ${_ent_VERBOSE}
	fi
	return 0
}
declare -fx 'verbose.set'

#X Function : color.set
#X Desc     : turn on/off colorized output from msg.* functions.
#X          : color is turned off if verbose() is also set to off.
#X Synopsis : color.set [ON|1 | OFF|0 | auto]
#X          : curstatus=$(color.set)
#X Example  : 
#X          : oldstatus=$(color.set)
#X          : color.set off
#X          : # do stuff... #
#X          : color.set $oldstatus
declare -ix _ent_COLOR=1
[ -t 1 ] && _ent_COLOR=1 || _ent_COLOR=0
color() { return $(( ! _ent_COLOR )); }
declare -fx color
color.set() {
	if ((${#@})); then 
		if [[ $1 == 'auto' ]]; then
			is.tty && status=1 || status=0
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


#X Global   : colorreset colordebug colorinfo colornotice colorwarning colorerr colorcrit coloralert coloremerg
#X Desc     : Colors used by entities msg.* functions.
#X          : emerg alert crit err warning notice info debug
#X          : panic (dep=emerg) err (dep=error) warning (dep=warn)
#X See Also :
declare  -x colorreset="\x1b[0;39;49m"
declare  -x color0="\x1b[0;39;49m"
declare  -x colordebug="\x1b[35m"
declare  -x colorinfo="\x1b[32m"
declare  -x colornotice="\x1b[34m"
declare  -x colorwarning="\x1b[33m"				; declare -nx colorwarn='colorwarning'
declare  -x colorerr="\x1b[31m"						; declare -nx colorerror='colorerr'
declare  -x colorcrit="\x1b[1;31m"				; declare -nx colorcritical='colorcrit'
declare  -x coloralert="\x1b[1;33;41m"
declare  -x coloremerg="\x1b[1;4;5;33;41m";	declare -nx colorpanic='coloremerg'

#X Function : version.set
#X Desc     : set or return version of the script.
#X Defaults : '0.00 prealpha'
#X Synopsis : version.set verstring
#X          : $(version.set)
#X Example  : version.set '4.20 beta'
#X          : ver=$(version.set)
declare -x _ent_SCRIPT_VERSION='0.00 prealpha'
version() { echo -n "$_ent_SCRIPT_VERSION"; return 0; }
declare -fx version
version.set() {
	if ((${#@})); then _ent_SCRIPT_VERSION="$1"
								else echo -n "${_ent_SCRIPT_VERSION}"
	fi
	return 0
}
declare -fx 'version.set'


#X Function : dryrun.set
#X Desc     : general purpose global var for debugging. 
#X Defaults : 0
#X Synopsis : dryrun.set [[on|1] | [off|0]]
#X          : $(dryrun.set)
#X Example  : dryrun.set off
#X          : ((dryrun.set)) || doit.sh
declare -ix _ent_DRYRUN=0
dryrun() { return $((! _ent_DRYRUN)); }
declare -fx dryrun
dryrun.set() {
	if (($#)); then 
		_ent_DRYRUN=$(onoff "${1}" "${_ent_DRYRUN}")
	else 
		#	-- SC2086: Double quote to prevent globbing and word splitting.
		# shellcheck disable=SC2086
		echo -n ${_ent_DRYRUN}
	fi
	return 0
}
declare -fx 'dryrun.set'

#X Function: debug debug.set
#X Desc    : general purpose global setting for debugging. 
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
debug() {	return $((! _ent_DEBUG)); }
declare -fx debug
debug.set() {
	if (($#)); then 	_ent_DEBUG=$(onoff "${1}" ${_ent_DEBUG})
	else							echo ${_ent_DEBUG}
	fi
	return 0
}
declare -fx 'debug.set'


#X Function : strict.set
#X Desc     : sets/unsets options errexit, nounset and pipefail. 
#X          : Default is OFF.
#X          : Use of "strict.set on" is recommended for development.
#X          : Without parameters, only echos current status (0|1)
#X Synopsis : strict.set [[on|1] | [off|0*]]
#X          : curstatus=$(strict.set)
#X Example  : strict.set on
#X          : curstatus=$(strict.set)
declare -ix _ent_STRICT=0
strict() { return $((! _ent_STRICT)); }
declare -fx strict
strict.set() {
	if (($#)); then
	 	local opt='+'
		_ent_STRICT=$(onoff "${1}" ${_ent_STRICT})
		((_ent_STRICT)) && opt='-'
		set ${opt}o errexit ${opt}o nounset ${opt}o pipefail #${opt}o noclobber
	else
		echo -n ${_ent_STRICT}
	fi
	return 0
}
declare -fx 'strict.set'

#X Function : trap.function
#X Synopsis : trap.function [{ bash_exit_trap_function } ]
declare -x _ent_EXITTRAPFUNCTION='{ cleanup $? ${LINENO:-0}; }'
trap.function() {
	if (($#));	then _ent_EXITTRAPFUNCTION="$1" 
							else echo -n "$_ent_EXITTRAPFUNCTION"
	fi
	return 0
}
declare -fx 'trap.function'

#X Function : trap.set
#X Synopsis : trap.set [[on|1] | [off|0]]
declare -ix _ent_EXITTRAP=0
trap.set() {
	if (($#)); then
		_ent_EXITTRAP=$(onoff "${1}" ${_ent_EXITTRAP})
		if ((_ent_EXITTRAP)); then
	    #-- SC2064: Use single quotes, otherwise this expands now rather than when signalled.
			# shellcheck disable=SC2064
			trap "$_ent_EXITTRAPFUNCTION" EXIT
		else
			trap -- EXIT
		fi
	else
		echo -n $_ent_EXITTRAP
	fi
	return 0
}
declare -fx 'trap.set'

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
	if (( exitcode )); then
		msg.err "script=$PRG:exit=$exitcode:line=${2:-}:1=${1:-}:f=${FUNCNAME[@]}:ln=${BASH_LINENO[@]}:s=${BASH_SOURCE[@]}}"
		if ((_ent_DEBUG)); then
			msg.info "$(set | grep "^_ent_" | grep -v "^_ent_LOCK")"
			msg.info "$(set | grep "^BASH"  | grep -v BASH_VERSINFO)"
		fi
	fi
	exit $exitcode
}
declare -fx cleanup


#X Function : synopsis
#X Desc     : display usage information for the script. optionally exit.
#X          : calling script should define its own 'synopsis' function.
#X Synopsis : synopsis [-x|--exit]
#X Example  : synopsis --exit
synopsis() {
	local -i xt=0
	while (($#)); do
		case "${1,,}" in
			-x|--exit|exit)	xt=1	;;
			*)							msg.die log "Bad command line argument '$1'!" ;;
		esac
		shift
	done
	cat <<-syn
	Usage: $PRG
 
	syn
	((xt)) && exit $xt
}
declare -fx synopsis


#X Function : msg
#X Desc     : if verbose.set is enabled, send strings to output.
#X          : embedded chars (\n \t etc) enabled by default.
#X Synopsis : msg [-n] {str} [[-n] {str} ...]
#X          : -n  suppress line feed, applied separately to each 
#X          :     string argument
#X Example  : msg "hello world!" "it's so nice to be back!"
msg() { ((_ent_VERBOSE)) && _printmsg "$@"; }
declare -fx msg

msg.debug() {
	((_ent_DEBUG)) || return 0
	declare log="${1:-}"
	[[ "${log,,}" == 'log' ]] && shift
	[[ -z "$log" ]] && log=X
	__msgx "$log" 'debug' "${_ent_VERBOSE}" "$@"
	return 0
}
declare -fx 'msg.debug'

#X Function : __msgx
#X Desc     : output string to terminal with color.
#X          : embedded chars (\n \t etc) enabled by default.
#X Synopsis : __msgx log msglevel verbose [string ...]
#X          : msglevel is one of:
#X          :    reset debug info notice warning error
#X          :    critical alert emergency
#X Example  : __msgx log info 1 "hello world!" "it's so nice to be black!"
__msgx() {
	local log="$1" msglevel="$2" verbose="$3"
	shift 3
	if [[ "${log}" == 'log' ]]; then
		systemd-cat -t "$PRG" -p ${msglevel} echo "$@"
	fi
	if ((verbose)); then
    if ((_ent_COLOR)); then nc=color$msglevel; echo -ne "${!nc}"; fi
		_printmsg "$@"
		((_ent_COLOR)) && echo -ne "${colorreset}"
	fi
	return 0
}
declare -fx __msgx

#X Function : msg.info
#X Desc     : output an information message, with option to write to systemd journal.
#X Synopsis : msg.info [log] string [string ...]
#X          : 	'log'	if specified, write log entry to journal info. 'log' is positional, 
#X					:	and must appear before the strings to be printed.
#X          : if verbose() enabled, write string/s to stdout.
#X Example  : msg.info "Sir. There's something I think you should know."
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

#X Function : msg.sys
#X Desc     : output an informational message, with option to write to systemd journal.
#X Synopsis : msg.sys [log] string [string ...]
#X          : 	'log'		if specified, write log entry to journal info.
#X          : 	string	if verbose() enabled, write string/s to stdout.
#X Example  : msg.sys "Sir. There's something I think you should know."
msg.sys() {
	declare log="${1:-}"
	[[ "${log}" == 'log' ]] && shift
	__msgx "$log" "notice" "${_ent_VERBOSE}" "$@"
	return 0
}
declare -fx 'msg.sys'
	alias msgsys='msg.sys' #X legacy X#
	alias sysmsg='msg.sys' #X legacy X#

#X Function : msg.warn
#X Desc     : output a warning message, with option to write to systemd journal.
#X          : message is coloured red on terminals.
#X Synopsis : msg.warn [log] string [string ...]
#X          : 	'log'		if specified, write log entry to journal info.
#X          : 	string	if verbose() enabled, write string/s to stdout.
#X Example : msg.warn log "Pardon me, Sir." "Is this supposed to happen?"
msg.warn() {
	declare log="${1:-}"
	[[ "${log}" == 'log' ]] && shift || log='X'
	__msgx "$log" 'warning' "${_ent_VERBOSE:-0}" "$@"
	return 0
}
declare -fx 'msg.warn'
	alias msgwarn='msg.warn'	#X legacy X#
	alias warnmsg='msg.warn'	#X legacy X#

#X Function : msg.err
#X Desc     : output an error message, with option to write to systemd journal.
#X          : message is coloured red on terminals.
#X Synopsis : msg.err [log] string [string ...]
#X          : 'log'		if specified, write log entry to journal err.
#X          : string	write string/s to stderr.
#X Example  : msg.err log "Sir!" "I think you better come here."
msg.err() {
	declare log="${1:-}"
	[[ "${log}" == 'log' ]] && shift
	__msgx >&2 "$log" 'err' '1' "$@"
	return 0
}
declare -fx 'msg.err'
	alias msgerr='msg.err'	#X lecacy X#
	alias errmsg='msg.err'	#X legacy X#

#X Function : msg.die
#X Desc     : output an error message, with option to write to systemd journal.
#X          : message is coloured red on terminals.
#X          : immediately exit 1 from the script.
#X Synopsis : msg.die [log] string [string ...]
#X          :  'log'   if specified, write log entry to journal err.
#X          :  string  write string/s to stderr.
#X Example  : msg.die log "I'm sorry, Sir." "I give up." "There's nothing more I can do."
msg.die() {
	declare log="${1:-}"
	[[ "${log}" == 'log' ]] && shift
	__msgx >&2 "$log" "crit" "1" "$@" 'Aborting.'
	exit 1
}
declare -fx 'msg.die'
	alias msgdie='msg.die' #X legacy X#
	alias diemsg='msg.die' #X legacy X#
	alias msgdir='msg.die' #X for butter fingers #X

#X Function : msg.crit
#X Desc     : output a critical error message, with option to write to systemd journal.
#X          : message is coloured red on terminals.
#X          : immediately exit 1 from the script.
#X Synopsis : msg.crit [log] string [string ...]
#X          : 'log'   if specified, write log entry to journal err.
#X          :  string  write string/s to stderr.
#X Example  : msg.crit log "Good god!" "Oh, the Humanity..."
msg.crit() {
	declare log="${1:-}"
	[[ "${log}" == 'log' ]] && shift
	__msgx >&2 "$log" "emerg" "1" "$@" 'Call Sysadmin immediately.'
	#mail --to sysadmin@megacorp.dev -s "hello Sir, how are you? are you sitting down?" <<< "Sir, a funny thing just happened."
	exit 1
}
declare -fx 'msg.crit'
	alias msgcrit='msg.crit' #X legacy X#
	alias critmsg='msg.crit' #X legacy X#

#X Function : msg.line 
#X Desc     : print an underline from current cursor position to end of screen
#X Synopsis : msg.line
#X Example  : msg.line
msg.line() {
	((_ent_VERBOSE)) || return
	local sx sz IFS=' '
	sz=( $(stty size) )
	if (( ${#sz[@]} )); then
		sx=$(( (sz[1] - (TABSET * TABWIDTH)) - 1 ))
	else
		sx=$(( (COLUMNS - (TABSET * TABWIDTH)) - 1))
	fi
	IFS=$' \t\n'
	msg "$(printf '_%.0s' $(seq 1 "${sx:-1}") )"
	return 0
}
declare -fx 'msg.line'
	alias msgline='msg.line'

#X Function : tab.set tab.width
#X Synopsis : tab.set [offset]; tab.width [tabvalue]
#X Desc     : tab.set    set tab position for output from msg.* functions.
#X          : tab.width  set tab width (default 4).
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
	if ((${#@})); then
		TABWIDTH=$((${1}))
		((_ent_COLOR)) && tabs "$TABWIDTH"
	else
		echo -n "${TABWIDTH}"
	fi
	return 0
}
declare -fx 'tab.width'

declare -ix TABSET=0
tab.set() {
	if ((${#@})); then
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

_printmsg() {
	local line IFS=$'\t\n' lf=''
	for line in "$@"; do
		[[ "${line}" == '-n' ]] && { lf='-n'; continue; }
		((TABSET)) && printf '\t%.0s' $(seq 1 ${TABSET})
		echo -e $lf "${line}"
		lf=''
	done
	return 0
}
declare -fx	_printmsg

#X Function : trim ltrim rtrim
#X Desc     : trim   strip string of leading and trailing space chars
#X          : ltrim  strip string of leading space chars
#X          : rtrim  strip string of trailing space chars
#X Synopsis : trim string
#X Example  : str=" 123 "; str=$(trim "$str")
trim()  { 
	local v="$*"
	v="${v#"${v%%[![:space:]]*}"}"
	v="${v%"${v##*[![:space:]]}"}"
	echo -n "$v"
}
ltrim() {
	local v="$*"
	v="${v#"${v%%[![:space:]]*}"}"
	echo -n "$v"
}
rtrim() {
	local v="$*"
	v="${v%"${v##*[![:space:]]}"}"
	echo -n "$v"
}
declare -fx trim rtrim ltrim

#X Function : exit_if_not_root
#X Desc     : If not root user, print failure message and exit script.
#X Synopsis : exit_if_not_root
exit_if_not_root() {
	is.root || msg.die "$PRG can only be executed by root user."
	return 0
}
declare -fx exit_if_not_root

is.root() {
	[[ "$(whoami)" == 'root' || $EUID == 0 ]] && return 0
	return 1
}
declare -fx 'is.root'

	
#X Function : ask.yn
#X Desc     : Ask y/n question,d return 0/1 
#X          : NOTE: if verbose() is disabled, or there is no tty, ask.yn will 
#X					: *always* return 0, without printing the string or waiting for a 
#X					: response.
#X Synopsis : ask.yn string
#X Example  : ask.yn "Continue?" || msg.die 'Not Continuing.'
ask.yn() {
	((_ent_VERBOSE)) || return 0
	is.tty || return 0
	local question="${1:-}" yn=''
	question=$(msg.warn "${question} (y/n)")
	question="${question//$'\n'/ }"
	while true; do
		read -e -n1 -r -p "${question}" yn
		case "${yn,,}" in
			[y]* ) return 0;;
			[n]* ) return 1;;
			* ) echo "Please answer yes or no.";;
		esac
	done
}
declare -fx 'ask.yn'
	alias askyn='ask.yn' #X legacy X#

#X Function : entities.help 
#X Desc     : display help info about Entities functions and variables.
#X Synopsis : entities.help [function|globalvar|localvar|file] | [-s|--search searchstring] [-h|--help]
#X Example  : entities.help ask.yn msg.info
entities.help() {
	"$ENTITIES/docs/entities.help" "$@"
	return 0
}
declare -fx 'entities.help'

#X Function : check.dependencies
#X Desc     : check for script dependencies (programs, scripts, or functions).
#X Synopsis : check.dependencies [-q|--quiet] name [...]
#X          : 	name				is the name of a program, script or function.
#X					:		-q|--quiet	do not print 'dependency-not-found' messages.
#X Example  : (( check.dependencies dirname ln )) && msg.die "Dependencies missing."
check.dependencies() {
	((${#@})) || return 0
	local needed_dep=''
	local -a missing_deps=''
	local -i missing=0
	if [[ "$1" == "--quiet" || "$1" == '-q' ]]; then
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
			>&2 echo "These dependenc$( ((missing==1)) && echo 'y is' || echo 'ies are' ) missing: '$(trim "${missing_deps[@]}")'"
	return $missing
}
declare -fx 'check.dependencies'


#X Function : is.tty 
#X Desc     : return 0 if tty available, otherwise 1.
#X Synopsis : is.tty
#X Example  : is.tty && ask.yn "Continue?"
is.tty() {
	tty --quiet	# [[ -t 0 ]] is this the same??
	return $?
}
declare -fx 'is.tty'
	alias is_tty='is.tty'
	

#X Function : is.interactive
#X Desc     : return 0 if tty available, otherwise 1.
#X          : this function should be used as a comparison function
#X Synopsis : is.interactive [report|noreport*]
#X Example  : is.interactive && ask.yn "Continue?"
is.interactive() {
	declare report=${1:-}
	declare -i isit=0 echoit=0

	# echo results? default is no.
	if [[ -n $report ]]; then
		case "${1:-}" in
			report)		echoit=1;;
			noreport)	echoit=0;;
		esac
	fi
	
	# look for positives first
	if [[ -t 1 ]]; then 
		isit=1
    ((echoit)) && echo "${isit}: STDOUT is attached to TTY."
	fi

	if [[ "${PS1+x}" == 'x' ]]; then
		((echoit)) && echo "${isit}: PS1 is set. This is possibly an interactive shell."
		if ((${#PS1} > 1)); then
			isit=1
			((echoit)) && echo "${isit}: PS1 is set and has a length -gt 1. This is very probably an interactive shell."
		fi
	fi
	
  if [[ "$-" == *"i"* ]]; then
		isit=1
  	((echoit)) && echo "${isit}: \$- = *i*"
	fi

	# look for negatives		
	if [[ -p /dev/stdout ]]; then
		isit=0
    ((echoit)) && echo "${isit}: STDOUT is attached to a pipe."
	fi

	if [[ ! -t 1 && ! -p /dev/stdout ]]; then
		isit=0
    ((echoit)) && echo "${isit}: STDOUT is attached to a redirection."
	fi
	
	# echo the result
	if ((echoit)); then
		((isit)) && echo '1: is interactive' || echo '0: is not interactive'
	fi

	return $(( ! isit ))
}
declare -fx 'is.interactive'
	alias is_interactive='is.interactive'

#X Function: trap.breakp
#X Synopsis: trap.breakp [msg]
#X Desc    : prompt to exit script or continue.
trap.breakp() { 
	local b='' prompt=${1:-}
	((${#prompt})) && prompt=" $prompt"
	read -e -n1 -p "breakpoint${prompt}: continue? y/n " b
	[[ "${b,,}" == 'y' ]] || exit 1
	return 0
}
declare -fx 'trap.breakp'
	alias breakp='trap.breakp'

#--_ent_MINIMAL if defined, then don't do this section
if ((! ${_ent_MINIMAL:-0})); then
#X File: IncludeModules 
#X Desc: By default, all *.bash module files located in  
#X     : $ENTITIES/entities.d/** are 
#X     : automatically included in the entities.bash source file. 
#X     :
	if [[ -d "$ENTITIES/entities.d" ]]; then
		declare _e
		shopt -s globstar
		for _e in $ENTITIES/entities.d/**/*.bash; do
			if [[ -r "$_e" ]] && [[ ! -L "$_e" ]] ; then
				source "$_e" || echo >&2 "**Source file [$_e] could not be included!" && true
			fi
		done
		unset _e
	fi
	
	#--check dependencies if not minimal
	if ! check.dependencies \
			basename dirname readlink mkdir ln cat \
    	systemd-cat stty wget base64 seq tty find touch tree lynx; then
		echo >&2 'Warning: Dependencies not found. Entities cannot run.'	
	fi 
fi
#^^_ent_MINIMAL

#X Global   : _entities_
#X Desc     : Integer flag to announce that entities.bash has been loaded. 
#X Defaults : 0
declare -xig __entities__=1
declare -xng _ent_LOADED='__entities__'

# expand all the aliases defined above.
shopt -s expand_aliases # Enables alias expansion.

_ent_scriptstatus+="entities loaded|\n"
#-Function Declarations End --------------------------------------------------
#fin
