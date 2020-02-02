#!/bin/bash
	entROOT=$OKROOT/entities
	source $entROOT/entities.bash || exit
	strict.set on

	cd "$entROOT" || exit

	entversionfile="$entROOT/entities.d/_ent_version.bash"

main() {
	exit_if_not_root
	
	msg "Make entities.bash production ready." "PRG=$PRG" "PRGDIR=$PRGDIR"
	if [[ "${1:-}" != '--auto' ]]; then
		ask.yn 'Proceed?' || exit 1
	fi
	msg ''
	tab.set ++
	msg.info 'Building version/build file...'
	IFS='.'
	declare -a arr
	arr=( ${_ent_VERSION:-} )
	day=${arr[3]:-}
	inc=${arr[4]:-}
	IFS=$OLDIFS

	today=$(( ($(date +%s) - $(date +%s -d "2019-06-21 04:20"))/60/60/24 ))
	if (( day != today )); then
		arr[3]=$today
		arr[4]=0
	else
		arr[4]=$((++inc))
	fi
	build="${arr[@]:0:5}"
	build=${build// /.}

	cat >$entversionfile <<-eot
		#X Global   : _ent_VERSION 
		#X Desc     : Return version/build of entities.bash.
		#X          : returns string in form of
		#X          : majorver.minorver.420.day0.daybuild
		#X          : where day0 is days since 2019-06-21
		#X          :       daybuild is an incremental counter 
		#X          :       of how many builds have been made on day0
		declare -x _ent_VERSION='${build}'
	
	eot
	
	chown sysadmin:sysadmin "$entversionfile"; chmod 644 "$entversionfile"
	source "$entversionfile"
	tab.set ++
	msg.info "version/build: ${_ent_VERSION:-}" ""
	tab.set --

	$PRGDIR/_make.minimal.bash --auto
	msg ''

	$entROOT/docs/entities.help.make --auto
	msg ''
		
	msg.info 'Fixing owner-permissions...'
	fixperms
	msg ''
}

fixperms() {
	[[ -z "$entROOT" ]] && exit 1
	pwd=$(pwd)
	cd "$entROOT" || exit 1
	chown sysadmin:sysadmin * -R || exit
	find -type d -exec chmod 770 {} \;
	find -type f -exec chmod u+rw,g+rw,o-w {} \;
	cd "$pwd"
}

main "$@"
#fin
