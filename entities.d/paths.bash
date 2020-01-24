# path-add()
path-add() {
	local cmd=()
	local -i prepend=0 export_path=1 test_dir=1
	while (($#)); do
		case "$1" in
			-r|--prepend)			prepend=1	;;
			-o|--postpend)		prepend=0 ;;
			-n|--no-export)		export_path=0 ;;
			-t|--no-test-dir)	test_dir=0;;
			*)								cmd+=( "$1" ) ;;
		esac
		shift
	done
	path-delete "${cmd[@]}" /dev/null
	for p in ${cmd[@]}; do
		[[ "$test_dir" == "1" && ! -d "$p" ]] && return 1
		if ((prepend)); then
			PATH="${p}:${PATH}"
		else
			PATH="${PATH}:${p}"
		fi
	done
	((export_path)) && export PATH
	return 0
}
declare -fx path-add

# path-delete()
path-delete() {
	local newpath='' IFS=':'
	while ((${#@})); do
		for p in ${PATH}; do
			[[ "$p" == "$1" || "$p" == '' ]] && continue
			newpath+="${p}:"
		done
		shift
	done
	while [[ "${newpath:0:1}" == ':' ]]; do newpath="${newpath:1}"; 		done
	while [[ "${newpath: -1}" == ':' ]]; do newpath="${newpath:0: -1}"; done
	PATH="$newpath"
	return 0
}
declare -fx path-delete

