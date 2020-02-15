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
	if ((${#@})); then lockfile.add "$1"
								else echo -n "${_ent_LOCKFILE}"
	fi
}
declare -fx lockfile
#X Function : lockfiles
#X Desc     : return array of locked files
#X Synopsis : lockfiles
#X Example  : files=$(lockfiles)
lockfiles() {
	echo -n "${_ent_LOCKFILES[@]}"
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
		return
	elif (( ${#@} % 2 )); then
		lockfiles.add "$@" "${_ent_LOCKTIMEOUT}"
		return
	fi
	# make new lock files
	declare -a newlockfiles=($@)
	local -i j i
	local lk='' to=''
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
	if ((${#@})); then
		local lk lf
		for lk in ${@}; do
			rm -f "${lk}"
			_ent_LOCKFILES=( ${_ent_LOCKFILES[@]/$lk} )
			lf=${#_ent_LOCKFILES[@]}; ((lf+=-1))
			if ((lf>=0)); then _ent_LOCKFILE="${_ent_LOCKFILES[$lf]}"
										else _ent_LOCKFILE=''
			fi
		done
	else
		[[ ${_ent_LOCKFILE} ]] && lockfiles.delete "${_ent_LOCKFILE}"
	fi
}
declare -fx lockfiles.delete
#X Function : lockfiles.delete.all
#X Desc     : delete all lock files in lockfiles() stack. usually done on script exit (see cleanup()).
#X Synopsis : lockfiles.delete.all
lockfiles.delete.all() {
	((${#_ent_LOCKFILES[@]})) && lockfiles.delete "${_ent_LOCKFILES[@]}"
	_ent_LOCKFILES=()
	_ent_LOCKFILE=''
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
}
declare -fx lockfiles.timeout
#----------------

