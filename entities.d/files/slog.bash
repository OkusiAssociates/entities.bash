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
}
slog.prefix.eval() {
	eval "echo -n $(slog.prefix)"
}
slog.truncate() {
	_slog_count=0
	> "$(slog.file)"
}

