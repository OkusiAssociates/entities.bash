#!/bin/bash
declare -- PRG PRGDIR
if ((SHLVL > 1 && ${#0} > 0)); then
p_="$(/bin/readlink -e "${0:-}")"
PRG="$(/usr/bin/basename "${p_}")"
PRGDIR="$(/usr/bin/dirname "${p_}")"
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
else
p_="$(/bin/readlink -e "${0:-}")"
PRG="$(/usr/bin/basename "${p_}")"
PRGDIR="$(/usr/bin/dirname "${p_}")"
fi
if (( "${__entities__:-}" )); then
(($#)) || return 0;  # entities is already loaded, and no parameter has been given, so do not reload.
while (($#)); do
case "${1,,}" in
new|nopreserve|--nopreserve|-n)		break ;;
preserve|--preserve|-p)						return 0;;
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
-*)	echo >&2 "$0: Bad option '$1' in entities.bash!"; exit 1 ;;
*)	echo >&2 "$0: Bad argument '$1' in entities.bash!"; exit 1 ;;
esac
shift
done
fi
set +o errexit +o nounset +o pipefail
declare --  LF=$'\n' CR=$'\r' CH9=$'\t' OLDIFS="$IFS" IFS=$' \t\n'
declare -nx OIFS="OLDIFS"
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
declare -ix _ent_VERBOSE=$( [[ -t 0 ]] && echo 1 || echo 0)
verbose.set() {
if ((${#@})); then
_ent_VERBOSE=$(onoff "${1}")
else
echo -n ${_ent_VERBOSE}
fi
return 0
}
declare -fx verbose.set
declare -ix _ent_COLOR=1
color.set() {
((${#@})) && _ent_COLOR=$(onoff "${1}" "${_ent_COLOR}") || echo -n "${_ent_COLOR}"
return 0
}
declare -fx color.set
alias colour.set='color.set'		# for the civilised world
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
declare -p _ent_VERSION &>/dev/null || declare -r _ent_VERSION='4.20.420 beta'
declare -x _ent_SCRIPT_VERSION='0.00 prealpha'
version.set() {
((${#@})) && _ent_SCRIPT_VERSION="$1" || echo -n "${_ent_SCRIPT_VERSION}"
return 0
}
declare -fx version.set
declare -ix _ent_DRYRUN=0
dryrun.set() {
((${#@})) && _ent_DRYRUN=$(("$1")) || echo -n ${_ent_DRYRUN}
return 0
}
declare -fx dryrun.set
declare -ix _ent_DEBUG=0
debug.set() {
((${#@})) && _ent_DEBUG=$(("$1")) || echo -n ${_ent_DEBUG}
return 0
}
declare -fx debug.set
declare -x  _ent_LOCKFILE=''
declare -ax _ent_LOCKFILES=()
declare -ix _ent_LOCKTIMEOUT=86400
lockfile() {
((${#@})) && lockfile.add "$1" ||	echo -n "${_ent_LOCKFILE}"
return 0
}
declare -fx lockfile
lockfiles() {
echo -n "${_ent_LOCKFILES[@]}"
return 0
}
declare -fx lockfiles
lockfiles.add() {
if (( ${#@} == 0 )); then
lockfiles.add "/run/lock/$PRG.$RANDOM" "${_ent_LOCKTIMEOUT}"
return 0
elif (( ${#@} % 2 )); then
lockfiles.add "$@" "${_ent_LOCKTIMEOUT}"
return 0
fi
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
lockfiles.delete.all() {
((${#_ent_LOCKFILES[@]})) && lockfiles.delete "${_ent_LOCKFILES[@]}"
_ent_LOCKFILES=()
_ent_LOCKFILE=''
return 0
}
declare -fx lockfiles.delete.all
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
cleanup() {
[[ "${1:-}" == '' ]] && exitcode="$?" || exitcode="$1"
((_ent_DEBUG)) && msg.info "$PRG exit with code $exitcode."
exit $exitcode
}
declare -fx cleanup
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
declare -x _ent_EXITTRAPFUNCTION='{ cleanup "$?" "${LINENO:-}"; }'
trap.function() {
((${#@})) && _ent_EXITTRAPFUNCTION="$1" || echo -n "$_ent_EXITTRAPFUNCTION"
return 0
}
declare -fx trap.function
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
msg() { ((_ent_VERBOSE)) && _printmsg "$@"; return 0; }
declare -fx msg
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
msg.sys() {
declare log="${1:-}"
[[ "${log}" == 'log' ]] && shift
__msgx "$log" "notice" "${_ent_VERBOSE}" "$@"
return 0
}
declare -fx msg.sys
alias msgsys='msg.sys' # legacy
alias sysmsg='msg.sys' # legacy
msg.warn() {
declare log="${1:-}"
[[ "${log}" == 'log' ]] && shift || log='X'
__msgx "$log" warning "${_ent_VERBOSE}" "$@"
return 0
}
declare -fx msg.warn
alias msgwarn='msg.warn'	# legacy
alias warnmsg='msg.warn'	# legacy
msg.err() {
declare log="${1:-}"
[[ "${log}" == 'log' ]] && shift
__msgx >&2 "$log" "err" "1" "$@"
return 0
}
declare -fx msg.err
alias msgerr='msg.err' # make canonical
alias errmsg='msg.err'	# legacy
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
msg.crit() {
declare log="${1:-}"
[[ "${log}" == 'log' ]] && shift
__msgx >&2 "$log" "emerg" "1" "$@" 'Call Sysadmin immediately.'
exit 1
}
declare -fx msg.crit
alias msgcrit='msg.crit' # legacy
alias critmsg='msg.crit' # legacy
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
trim() { local v="$*";v="${v#"${v%%[![:space:]]*}"}";v="${v%"${v##*[![:space:]]}"}";echo -n "$v"; }
ltrim() { local v="$*";v="${v#"${v%%[![:space:]]*}"}";echo -n "$v"; }
rtrim() { local v="$*";v="${v%"${v##*[![:space:]]}"}";echo -n "$v"; }
declare -fx trim rtrim ltrim
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
exit_if_not_root() {
[[ "$USER" == 'root' || EUID==0 ]] || msg.die "$PRG can only be executed by root user."
return 0
}
declare -fx exit_if_not_root
str_str() {
local str
str="${1#*${2}}"
str="${str%%${3}*}"
echo -n "$str"
}

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
entities.help() {
$ENTITIES/docs/entities.help "$@"
return 0
}
declare -fx entities.help
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
is_tty() {
tty --quiet	# [[ -t 0 ]] is this the same??
return $?
}
declare -fx is_tty
is_interactive() {
declare report=${1:-}
declare -i isit=0 echoit=0
if [[ -n $report ]]; then
case "${1:-}" in
report)		echoit=1;;
noreport)	echoit=0;;
esac
fi

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
if [[ -p /dev/stdout ]]; then
isit=0
((echoit)) && echo "${isit}: STDOUT is attached to a pipe."
fi
if [[ ! -t 1 && ! -p /dev/stdout ]]; then
isit=0
((echoit)) && echo "${isit}: STDOUT is attached to a redirection."
fi

((isit)) && echo 1 || echo 0
return 0
}
declare -fx is_interactive
breakp() {
local b='' prompt=${1:-}
((${#prompt})) && prompt=" $prompt"
read -e -n1 -p "breakpoint${prompt}: continue? y/n " b
[[ "${b,,}" == 'y' ]] || exit 1
}
declare -fx breakp
for e in $ENTITIES/entities.*/*.bash; do
source "$e" || msg.err "Source file [$e] could not be included!"
done
shopt -s expand_aliases # Enables alias expansion.
if ! check.dependencies basename dirname readlink mkdir ln cat systemd-cat stty; then
msg.die 'Dependencies not found. Entities cannot run.'
fi
declare -xig __entities__=1
