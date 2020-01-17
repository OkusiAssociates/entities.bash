#!/bin/bash
# ENTITIES FOR BASH - standard script editing template for starting new scripts.
# To get a minimal version of this template without comments use std-template.min.sh.
source entities.bash || exit 1
#      ^^^^^^^^^^ on failure, check $PATH setting.
# vvvvv code below this line --------------------------------------------------------
	# vvvvv change preset global variables.
	#VERBOSE=1
	#DRYRUN=0
	#LOCKTIMEOUT=86400

	# go on, do it for the kids.
	strict.set on

	# vvvvv declare/initialise global variables.

# vvvvv main
# i like using a main() structure to keep everything orderly. 
# having it means you have to call main() a the very end of the script.
# you don't absolutely must use this. just '. entities.bash' and off you go.
main() {
	# vvvvv delete below if non-root users are permitted to execute.
	exit_if_not_root
	# vvvvv delete below if multiple instances on this script are permitted.
	exit_if_already_running
				
	# vvvvv scripting starts here.

		# to include a basic options handling code fragment, 
		# use std-args.inc.sh or std-args.inc.min.sh

}

# vvvvv functions



# there are default cleanup() and usage() stubs in std.sh
# but you should really do your own as the code develops. 
# usage: cleanup [exitcode]
cleanup() {
	[[ ${1-} == '' ]] && exitcode="$?" || exitcode="$1"

	# cleanup temp files and processes before exit.
	# if using exit_if_already_running function, .lock file must be deleted on exit.
	#lockfiles.delete.all

	exit $exitcode
}

# usage: usage [exit]
#    if word exit is used, immediately exit the script.
usage() {
	# for processing parameters/options use the std-args.inc.sh code fragment in main()
	cat <<-usage
		Usage: $PRG 
		
	usage
	[[ $1 == 'exit' ]] && exit 1
}

# vvvvv call user main() function above, or we won't go very far.
main "$@"
#fin
