#!/bin/bash
# shellcheck disable=SC2035
# shellcheck disable=SC2154

#X Intro    : entities.bash
#X Desc     : Entities Functions/Globals/Locals Declarations and Initialisations.
#X          : entities.bash is a light-weight function library for productive
#X          : programmers and administrators. - the soft machine
#X          : PRG=basename of current script. 
#X          : PRGDIR=directory location of current script, with softlinks 
#X          : resolved to actual location.
#X          : PRG/PRGDIR are *always* initialised as local vars regardless of 
#X          : 'preserve' status when loading entities.bash.
#X Depends  : basename dirname readlink mkdir ln cat systemd-cat printf stty
##X Local    : PRG PRGDIR 
#X Synopsis : source entities.bash [ [preserve*] | [new] | [load libname] 
#X          :                       | [no-load libname] | [load-to newdir] ] 
#X          : source entities.bash preserve 
#X          :       # ^ if entities.bash has already been loaded, 
#X          :       # init PRGDIR/PRG globals only then return.
#X          :       # if entities.bash has not been loaded, load it.
#X          :       # [preserve] is the default. 
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
	# script is being run
	if ((SHLVL > 1 && ${#0} > 0)); then
		p_="$(/bin/readlink -e "${0:-}")"
		PRG="$(/usr/bin/basename "${p_}")"
		PRGDIR="$(/usr/bin/dirname "${p_}")"

	# source entities has been executed at the shell command prompt
	elif ((${#BASH_SOURCE[0]})); then
		p_="$(/bin/readlink -e "${BASH_SOURCE[0]:-}")"
		PRG="$(/usr/bin/basename "${p_}")"
		PRGDIR="$(/usr/bin/dirname "${p_}")"
		if [[ -n "${ENTITIES:-}" ]]; then
			PATH="${PATH//\:${ENTITIES}/}"
			PATH="${PATH//\:\:/\:}"
		fi
		export ENTITIES="$PRGDIR"
		export PATH="${PATH}:${ENTITIES}"		
		__entities__=0
		
	# dunno ....
	else
		p_="$(/bin/readlink -e "${0:-}")"
		PRG="$(/usr/bin/basename "${p_}")"
		PRGDIR="$(/usr/bin/dirname "${p_}")"
	fi

#X Global   : __entities__
#X Desc     : Is entities.bash already loaded? If it is, then use current instance 
#X          : and return without reinitializing globals and functions. 
#X          : (--preserve). to override, and reload, use nopreserve.
#X          : (("${__entities__:-}")) || { echo >&2 'entities.bash not loaded!'; exit; }
if (( "${__entities__:-}" )); then
	(($#)) || return 0;  # entities is already loaded, and no parameter has been given, so do not reload.
	while (($#)); do
		case "${1,,}" in
			# new load
			new|nopreserve|--nopreserve|-n)		break ;;
			# does the calling script wish to preserve the current Entities environment/functions?
			# (preserve is the default)
			preserve|--preserve|-p)						return 0;;
			# load entities into a new location (like a ram drive)
			load) shift; tmp="${1:-}"
						mkdir -p "$tmp"
						if [[ ! -d "$tmp" ]]; then
							echo >&2 "Load directory $tmp not found!"
						else
							rsync -qavl $ENTITIES/* "$tmp/"
							(( $? )) &&	{ echo >&2 "rsync error $ENTITIES > $tmp"; return 0; } 
							[[ -n ${ENTITIES:-} ]] && PATH="${PATH//${ENTITIES}/}:$tmp"
							export PATH=${PATH//::/:}
							export ENTITIES=$tmp
							source $ENTITIES/entities.bash new
							return 0
						fi			
						;;
			# all other options are invalid, and entities.bash will die.
			-*)	echo >&2 "$0: Bad option '$1' in entities.bash!"; exit 1 ;;
			*)	echo >&2 "$0: Bad argument '$1' in entities.bash!"; exit 1 ;;
		esac
		shift
	done
fi

# turn off strict! (strict is default)
set +o errexit +o nounset +o pipefail


#X Global   : GlobalCharVars CH9 LF CR OLDIFS IFS
#X Desc     : Constant global char values 
#X Synopsis : LF=$'\n' CR=$'\r' CH9=$'\t' OLDIFS="$IFS" IFS=$' \t\n' 
#X Defaults : OLDIFS=$IFS     # captures existing IFS before assigning 'standard' IFS
#X          : IFS=$' \\t\\n'  # 'standard' IFS
#X Example  : str = "${LF}${CH9}This is a wrapping string.${LF}{$CH9}This is another sentence."
#X          : echo -e "$str"
declare --  LF=$'\n' CR=$'\r' CH9=$'\t' OLDIFS="$IFS" IFS=$' \t\n'
declare -nx OIFS="OLDIFS"


#X Function : onoff 
#X Desc     : return 1 if 'on', 0 if 'off'
#X Synopsis : onoff [[on|1] | [off|0]] [default]
#X          : for ambiguous value, return 'default' if defined, otherwise return 0.
#X Example  : onoff off 1
onoff() {
	local o="${1:-}"
	case "${o,,}" in
		on|1)			o=1;;
		off|0)		o=0;;
		*)				[[ ${2:-} ]] && o=$(( ${2} )) || o=0;; # yes, i know. but what am i to do?
	esac
	echo -n $((o))
	return 0
}
declare -fx onoff


#X Function : verbose.set 
#X Desc     : if it's a shell terminal then turn verbose ON by default,
#X          : otherwise, called from another script/program, turn verbose OFF.
#X          : verbose.set() status is used in the ask.yn() and msg.*() commands.
#X          : msg.sys(), msg.die() and msg.crit() will ignore verbose status.
#X Synopsis : verbose.set [[on|1] | [off|0]]
#X          : curstatus=$(verbose.set)      
declare -ix _ent_VERBOSE=$( [[ -t 0 ]] && echo 1 || echo 0)
verbose.set() {   
	if ((${#@})); then
		_ent_VERBOSE=$(onoff "${1}")
		#_ent_COLOR=$(onoff "${1}")
	else
		echo -n ${_ent_VERBOSE}
	fi
	return 0    	
}
declare -fx verbose.set

#X Function : color.set
#X Desc     : turn on/off colorized output from msg.* functions.
#X          : color is turned off if verbose() is also set to off.
#X Synopsis : color.set [on|1] | [off|0]
#X          : curstatus=$(color.set)
#X Example  : color.set off
#X          : status=$(color.set)
declare -ix _ent_COLOR=1
color.set() {
	((${#@})) && _ent_COLOR=$(onoff "${1}" "${_ent_COLOR}") || echo -n "${_ent_COLOR}"
	return 0   
}
declare -fx color.set
	alias colour.set='color.set'		# for the civilised world


#X Global   : colorreset color0 colordebug colorinfo colornotice colorwarning colorwarn colorerr colorerror colorcrit colorcritical coloralert coloremerg colorpanic coloremergency 
#X Desc     : colors used by entities msg.* functions.
#X          : emerg alert crit err warning notice info debug
#X          : panic (dep=emerg) error (dep=err) warn (dep=warning)
#X See Also :
declare  -x colorreset="\x1b[0;39;49m"
declare  -x color0="\x1b[0;39;49m"
declare  -x colordebug="\x1b[35m"
declare  -x colorinfo="\x1b[32m"
declare  -x colornotice="\x1b[34m"
declare  -x colorwarning="\x1b[33m"
declare -nx colorwarn='colorwarning'
declare  -x colorerr="\x1b[31m"
declare -nx colorerror='colorerr'
declare  -x colorcrit="\x1b[1;31m"
declare -nx colorcritical='colorcrit'
declare  -x coloralert="\x1b[1;33;41m"
declare  -x coloremerg="\x1b[1;4;5;33;41m"
declare -nx colorpanic='coloremerg'
#declare -nx coloremergency='coloremerg'    

#X Global   : _ent_VERSION 
#X Desc     : return version of Entities.
declare -p _ent_VERSION &>/dev/null || declare -r _ent_VERSION='4.20.420 beta'

#X Function : version.set
#X Desc     : set or return version of the script.
#X Defaults : '0.00 prealpha'
#X Synopsis : version.set verstring
#X          : $(version.set)
#X Example  : version.set '4.20 beta'
#X          : ver=$(version.set)
declare -x _ent_SCRIPT_VERSION='0.00 prealpha'
version.set() {
	((${#@})) && _ent_SCRIPT_VERSION="$1" || echo -n "${_ent_SCRIPT_VERSION}"
	return 0
}
declare -fx version.set


#X Function : dryrun.set
#X Desc     : general purpose global var for debugging. 
#X Defaults : 0
#X Synopsis : dryrun.set [[on|1] | [off|0]]
#X          : $(dryrun.set)
#X Example  : dryrun.set off
#X          : ((dryrun.set)) || doit.sh
declare -ix _ent_DRYRUN=0
dryrun.set() {
	((${#@})) && _ent_DRYRUN=$(("$1")) || echo -n ${_ent_DRYRUN}
	return 0
}
declare -fx dryrun.set

#X Function : debug.set
#X Desc     : general purpose global var for debugging. 
#X Defaults : 0
#X Synopsis : debug.set [[on|1] | [off|0]]
#X          : $(debug.set)
#X Example  : debug.set on
#X          : ((debug.set)) && msg "my debug message"
declare -ix _ent_DEBUG=0
debug.set() {
	((${#@})) && _ent_DEBUG=$(("$1")) || echo -n ${_ent_DEBUG}
	return 0
}
declare -fx debug.set


# lockfile constants and functions
declare -x  _ent_LOCKFILE=''
declare -ax _ent_LOCKFILES=()
declare -ix _ent_LOCKTIMEOUT=86400

#X Function : lockfile
#X Desc     : return name of current lock file in lockfiles() stack,
#X          : and optionally add a new lockfile.
#X          : default is one day. if you are using the .lockfile system,
#X          : you may wish to set this very differently
#X Synopsis : lockfile [newlockfile]
#X Example  : lck=$(lockfile)
lockfile() {
	((${#@})) && lockfile.add "$1" ||	echo -n "${_ent_LOCKFILE}"
	return 0
}
declare -fx lockfile
#X Function : lockfiles
#X Desc     : return array of locked files
#X Synopsis : lockfiles
#X Example  : files=$(lockfiles)
lockfiles() {
	echo -n "${_ent_LOCKFILES[@]}"
	return 0
}
declare -fx lockfiles
#X Function : lockfiles.add
#X Desc     : add a lock file to lockfiles stack
#X Synopsis : lockfiles.add [filename [timeout]] [filename timeout]...
#X Example  : files=$(lockfiles.add)
lockfiles.add() {
	# validate
	if (( ${#@} == 0 )); then
		lockfiles.add "/run/lock/$PRG.$RANDOM" "${_ent_LOCKTIMEOUT}"
		return 0
	elif (( ${#@} % 2 )); then
		lockfiles.add "$@" "${_ent_LOCKTIMEOUT}"
		return 0
	fi
	# make new lock files
	declare -a newlockfiles=($@)
	declare j i
	declare lk='' to=''
	for ((i=0; i < ${#newlockfiles[@]}; i+=2)); do
		j=$((i+1))
		lk="${newlockfiles[$i]}"
		to="${newlockfiles[$j]}"
		ts=$(date +'%s')
		to=$((ts+_ent_LOCKTIMEOUT))
		mkdir -p $(dirname "${lk}")
		cat > "$lk" <<-eot
			declare _LockingScript="$0"
			declare -i _LockCreated=${ts} # $(date +'%F %T' -d @${ts})
			declare -i _LockExpire=${to}  # $(date +'%F %T' -d @${to})
		eot
		_ent_LOCKFILE="$lk"
		_ent_LOCKFILES+=("${_ent_LOCKFILE}")
	done
	return 0
}
declare -fx lockfiles.add
#X Function : lockfiles.delete
#X Desc     : delete a lockfile. Whenever a lock is removed, lockfile() is assisgned to be 
#X          : the last item in the lockfiles() stack
#X Synopsis : lockfiles.delete [lockfile]
#X Example  : lockfiles.delete
lockfiles.delete() {
	if (( ${#@} == 0 )); then
		[[ ${_ent_LOCKFILE} ]] && lockfiles.delete "${_ent_LOCKFILE}"
		return 0
	fi
	for lk in ${@}; do
		rm -f "${lk}"
		_ent_LOCKFILES=( ${_ent_LOCKFILES[@]/$lk} )
		lf=${#_ent_LOCKFILES[@]}; ((lf+=-1))
		((lf>=0)) && _ent_LOCKFILE="${_ent_LOCKFILES[$lf]}" || _ent_LOCKFILE=''
	done
	return 0
}
declare -fx lockfiles.delete
#X Function : lockfiles.delete.all
#X Desc     : delete all lock files in lockfiles() stack. usually done on script exit (see cleanup()).
#X Synopsis : lockfiles.delete.all
lockfiles.delete.all() {
	((${#_ent_LOCKFILES[@]})) && lockfiles.delete "${_ent_LOCKFILES[@]}"
	_ent_LOCKFILES=()
	_ent_LOCKFILE=''
	return 0
}
declare -fx lockfiles.delete.all
#X Function: lockfiles.timeout
lockfiles.timeout() {
	if ((${#@})); then
		source "$1" || msg.die log "log file $1 not found, or not a entities log file!"
		return "$(( $(date +'%s') < _LockExpire ))"
	else
		lockfiles.timeout "${_ent_LOCKFILE}"
	fi
	return 0
}
declare -fx lockfiles.timeout
#----------------


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
strict.set() {
	if ((${#@})); then
	 	local opt='+'
		_ent_STRICT=$(onoff "${1}" ${_ent_STRICT})
		((_ent_STRICT)) && opt='-'
		set ${opt}o errexit ${opt}o nounset ${opt}o pipefail #${opt}o noclobber
	else
		echo -n ${_ent_STRICT}
	fi
	return 0
}
declare -fx strict.set

#X Function : cleanup
#X Desc     : a call to this function is made in the trap EXIT command.
#X          : on exiting the script this function will always be called.
#X          : you should define your own cleanup function to delete temporary
#X          : files and other detritus before terminating.
#X          : if you are not using the exit_if_already_running function
#X          : (in other words, you are allowing multiple instances of this
#X          : script to run at the same time) then you can delete the deletion
#X          : of the .lock file.
#X Synopsis : cleanup [exitcode]
#X Example  : cleanup
#X See Also : trap.set trap.function, exit_if_already_running
cleanup() {
	[[ "${1:-}" == '' ]] && exitcode="$?" || exitcode="$1"
	#lockfiles.delete.all
	((_ent_DEBUG)) && msg.info "$PRG exit with code $exitcode."
	exit $exitcode
}
declare -fx cleanup

#X Function : trap.set
#X Synopsis : trap.set [[on|1] | [off|0]]
declare -ix _ent_EXITTRAP=0
trap.set() {
	if ((${#@})); then
		_ent_EXITTRAP=$(onoff "${1}" $_ent_EXITTRAP)
		((_ent_EXITTRAP)) && trap "$_ent_EXITTRAPFUNCTION" EXIT || trap -- EXIT
	else
		echo -n ${_ent_EXITTRAP}
	fi
	return 0
}
declare -fx trap.set

#X Function : trap.function
#X Synopsis : trap.function [{ bash_exit_trap_function } ]
declare -x _ent_EXITTRAPFUNCTION='{ cleanup "$?" "${LINENO:-}"; }'
trap.function() {
	((${#@})) && _ent_EXITTRAPFUNCTION="$1" || echo -n "$_ent_EXITTRAPFUNCTION"
	return 0
}
declare -fx trap.function

#X Function : synopsis
#X Desc     : display usage information for the script. optionally exit.
#X          : calling script should define its own 'synopsis' function.
#X Synopsis : synopsis [-x|--exit]
#X Example  : synopsis --exit
synopsis() {
	local xt=0
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
	return 0
}
declare -fx synopsis


#X Function : msg
#X Desc     : if verbose.set is enabled, send strings to output.
#X          : embedded chars (\n \t etc) enabled by default.
#X Synopsis : msg string [string ...]
#X Example  : msg "hello world!" "it's so nice to be back!"
msg() { ((_ent_VERBOSE)) && _printmsg "$@"; return 0; }
declare -fx msg

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
	__msgx "$log" "info" "${_ent_VERBOSE}" "$@"
	return 0
}
declare -fx msg.info
	alias msginfo='msg.info' # legacy
	alias infomsg='msg.info' # legacy

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
declare -fx msg.sys
	alias msgsys='msg.sys' # legacy
	alias sysmsg='msg.sys' # legacy

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
	__msgx "$log" warning "${_ent_VERBOSE}" "$@"
	return 0
}
declare -fx msg.warn
	alias msgwarn='msg.warn'	# legacy
	alias warnmsg='msg.warn'	# legacy

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
	__msgx >&2 "$log" "err" "1" "$@"
	return 0
}
declare -fx msg.err
	alias msgerr='msg.err' # make canonical
	alias errmsg='msg.err'	# legacy

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
declare -fx msg.die
	alias msgdie='msg.die' # legacy
	alias diemsg='msg.die' # legacy
	alias msgdir='msg.die' # for butter fingers.

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
declare -fx msg.crit
	alias msgcrit='msg.crit' # legacy
	alias critmsg='msg.crit' # legacy

#X Function : msg.line 
#X Desc     : print an underline from current cursor position to end of screen
#X Synopsis : msg.line
#X Example  : msg.line
msg.line() {
	((_ent_VERBOSE)) || return 0
	local sx sz IFS=' '
	sz=( $(stty size) )
	if (( ${#sz[@]} > 0 )); then
		sx=$(( (${sz[1]} - (TABSET * TABWIDTH)) - 1 ))
	else
		sx=$(( (COLUMNS - (TABSET * TABWIDTH)) - 1))
	fi
	IFS=$' \t\n'
	msg $(printf '_%.0s' $(seq 1 $sx) )
	return 0
}
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
declare -fx tab.width

declare -ix TABSET=0
tab.set() {
	if ((${#@})); then
		case "${1}" in
			'0'|reset) 		TABSET=0;;
			'++'|forward)	TABSET=$((TABSET+1))			;;
			'--'|back	 	)	TABSET=$((TABSET-1))			;;
			 * 					)	if [[ "${1:0:1}" == '+' || "${1:0:1}" == '-' ]]; then
											TABSET=$(( TABSET + ${1} ))
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
declare -fx	tab.set

_printmsg() {
	local line IFS=$'\t\n'
	for line in "$@"; do
		((TABSET)) && printf '\t%.0s' $(seq 1 ${TABSET})
		echo -e "${line}"
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
trim() { local v="$*";v="${v#"${v%%[![:space:]]*}"}";v="${v%"${v##*[![:space:]]}"}";echo -n "$v"; }
ltrim() { local v="$*";v="${v#"${v%%[![:space:]]*}"}";echo -n "$v"; }
rtrim() { local v="$*";v="${v%"${v##*[![:space:]]}"}";echo -n "$v"; }
declare -fx trim rtrim ltrim

#X Function : slog slog.file slog.prefix slog.prefix.eval slog.truncate
#X Desc     : write strings to user log file
#X Synopsis : slog string [...]
#X Example  : source entities.bash new \\
#X          : 		|| { echo &>2 "source entities.bash not found!"; exit 1; }
#X          : main() {
#X          : 	slog.file "mylog.log"
#X          : 	echo 'my log: ' $(slog.file)
#X          : 	slog.truncate
#X          : 	slog.prefix --long
#X          : 	echo 'log prefix: ' $(slog.prefix)
#X          : 	for ((i=0; i<10; i++)); do
#X          : 	slog "test $i $RANDOM"
#X          : 	done
#X          : 	cat "$(slog.file)"
#X          : }
#X          : main "$@"
declare -ix _slog_count=0
slog() {
	for log in "${@}"; do
		((++_slog_count))
		echo "$(slog.prefix.eval) ${log}" >> $(slog.file)
	done
	return 0
}
declare -x _slog_file=''
slog.file() {
	if ((${#@})); then
		_slog_file="$1"
		_slog_count=0
	else
		[[ -z "$_slog_file" ]] && _slog_file="$PRGDIR/$PRG.log"
		echo -n "$_slog_file"
	fi
	return 0
}
declare -x _slog_prefix=''
slog.prefix() {
	if ((${#@})); then
		if [[ "$1" == '--long' ]]; then
			_slog_prefix="$(date -Ins) $USER"
		elif [[ "$1" == '--short' ]]; then
			_slog_prefix='$(date +"%s.%N")'
		else
			_slog_prefix="$1"
		fi
	else
		[[ -z "$_slog_prefix" ]] && _slog_prefix="$(date -Ins) $USER"
		echo -n "$_slog_prefix"
	fi
	return 0
}
slog.prefix.eval() {
	eval "echo -n $(slog.prefix)"
	return 0
}
slog.truncate() {
	_slog_count=0
	> "$(slog.file)"
	return 0
}

#X Function : exit_if_already_running
#X Desc     : if there is an instance of the script already being run on the
#X          : server, then throw an error message and exit 1 immediately.
#X          : this function is mostly used at the very
#X          : beginning of the script.
#X Synopsis : exit_if_already_running [locktimeout]
#X          : locktimeout optionally sets the _ent_LOCKTIMEOUT global. if the age of
#X          : the lock file+_ent_LOCKTIMEOUT is < than current time, then the
#X          : script is immediately exitted.
#X Example  : exit_if_already_running 60
exit_if_already_running() {
	(($#)) && _ent_LOCKTIMEOUT="$1"
	local lockfile="/run/lock/${PRG}.lock"
	if [[ -f "$lockfile" ]]; then
		if lockfiles.timeout $lockfile; then
			trap.set off	# we don't want to exit through the cleanup() function or we will clobber the .lock file.
			msg.die "$0 is currently running!" "Duplicate instances of this program are not permitted."
		fi
		msg.warn log "Lock file '$lockfile' is more than ${_ent_LOCKTIMEOUT} seconds old." "Relocking and Proceeding..."
		touch $lockfile
	else
		lockfiles.add "${lockfile}" ${_ent_LOCKTIMEOUT}
	fi
	return 0
}
declare -fx exit_if_already_running

#X Function : exit_if_not_root
#X Desc     : exit script if not root user
#X Synopsis : exit_if_not_root
exit_if_not_root() {
	[[ "$USER" == 'root' || EUID==0 ]] || msg.die "$PRG can only be executed by root user."
	return 0
}
declare -fx exit_if_not_root

#X Function : str_str
#X Desc     : return string that occurs between two strings
#X Synopsis : str_str string beginstr endstr 
#X Example  : param=$(str_str "this is a [[test]]] of str_str" '[[' ']]'
str_str() {
	local str
	str="${1#*${2}}"
 	str="${str%%${3}*}"
 	echo -n "$str"
}
	
#X Function : ask.yn
#X Desc     : ask y/n question and return 0/1 
#X          : NOTE: if verbose() is disabled, or there is no tty, ask.yn will 
#X					: *always* return 0, without printing the string or waiting for a 
#X					: response.
#X Synopsis : ask.yn string
#X Example  : ask.yn "Continue?" || msg.die 'Not Continuing.'
ask.yn() {
	((_ent_VERBOSE)) || return 0
	is_tty || return 0
	local question="${1:-}" yn
	while true; do
		question=$(msg.warn "${question} (y/n)")
		question="${question//$'\n'/ }"
		read -p "${question}" yn
		case "${yn,,}" in
			[y]* ) return 0;;
			[n]* ) return 1;;
			* ) echo "Please answer yes or no.";;
		esac
	done
}
declare -fx ask.yn
	alias askyn='ask.yn'

#X Function : entities.help 
#X Desc     : display help info about Entities functions and variables.
#X Synopsis : entities.help [function|globalvar|localvar|file] | [-s|--search searchstring] [-h|--help]
#X Example  : entities.help ask.yn msg.info
entities.help() {
	$ENTITIES/docs/entities.help "$@"
	return 0
}
declare -fx entities.help

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
			msg.err "These dependenc$( ((missing==1)) && echo 'y is' || echo 'ies are' ) missing: '$(trim "${missing_deps[@]}")'"
	return $missing
}
declare -fx check.dependencies


#X Function : is_tty 
#X Desc     : return 0 if tty available, otherwise 1.
#X Synopsis : is_tty
#X Example  : is_tty && ask.yn "Continue?"
is_tty() {
	tty --quiet	# [[ -t 0 ]] is this the same??
	return $?
}
declare -fx is_tty


#X Function : is_interactive
#X Desc     : return 0 if tty available, otherwise 1.
#X          : this function should be used as a comparison function
#X Synopsis : is_interactive [report|noreport*]
#X Example  : is_interactive && ask.yn "Continue?"
is_interactive() {
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
	((isit)) && echo 1 || echo 0

	return 0
}
declare -fx is_interactive

#X Function: breakp
#X Synopsis: breakp [msg]
#X Desc    : prompt to exit script or continue.
breakp() { 
	local b='' prompt=${1:-}
	((${#prompt})) && prompt=" $prompt"
	read -e -n1 -p "breakpoint${prompt}: continue? y/n " b
	[[ "${b,,}" == 'y' ]] || exit 1
}
declare -fx breakp

#X File: IncludeModules 
#X Desc: By default, all .bash module files located in  
#X     : ENTITIES/entities.* directories are automatically included in 
#X		 : the entities.bash source file. 
#X     :
for e in $ENTITIES/entities.*/*.bash; do
	source "$e" || msg.err "Source file [$e] could not be included!"
done


#-Function Declarations End --------------------------------------------------


# expand all the aliases defined above.
shopt -s expand_aliases # Enables alias expansion.

if ! check.dependencies basename dirname readlink mkdir ln cat systemd-cat stty; then
	msg.die 'Dependencies not found. Entities cannot run.'	
fi 

#X Global   : _entities_
#X Desc     : Integer flag to announce that entities.bash has been loaded. 
#X Defaults : 0
declare -xig __entities__=1


# handing over to user.
#X File: entities-user.inc.php
#X Desc: If a file with the name of entities-user.inc.sh exists in the
#X     : Entities directory, is is automatically included at the
#X     : end of the Entities script.
#X     : By default, entities-user.inc.sh is symlinked to /dev/null.
#X     : User should change this to point at their own bash script.
#X     : User should not store their include script in the Entities directory.
#X     : This file can be used to over-ride Entities defaults and set to
#X     : User's commonly used defaults for global variables and functions,
#X     : without having to change code in the core Entities script.
#declare -x _ent_userfile="$PRGDIR/entities-user.inc.sh"
#[[ -r "${_ent_userfile}" ]] && source "${_ent_userfile}"


#return 0
#fin
