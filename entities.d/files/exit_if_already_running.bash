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
}
declare -fx exit_if_already_running

