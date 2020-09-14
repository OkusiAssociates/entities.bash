#!/bin/bash
#echo "EDITOR=$EDITOR"
#source $OKROOT/entities/entities.d/editor.set.bash
	
# joe
#   for f in /usr/share/joe/syntax/*.jsf; do basename -s '.jsf' "$f"; done
# nano
#   for f in /usr/share/nano/*.nanorc; do basename -s '.nanorc' "$f"; done
#   -Y <str>   --syntax=<str>      Syntax definition to use for coloring

# File stats from Scripts directory
#   4683 ASCII text
#    411 Bourne-Again shell script
#    233 XML 1.0 document
#    105 HTML document
#     41 POSIX shell script
#     17 PHP script
#     12 C source
#      6 SMTP mail
#      5 exported SGML document
#      2 Windows WIN.INI
#      2 troff or preprocessor input
#      2 TeX document
#      2 Python script
#      2 Non-ISO extended-ASCII text
#      1 Perl5 module source
#      1 BSD makefile script         

#     38 a /usr/bin/env bats script
#     11 a /usr/bin/php script
#      3 a /usr/bin/env /bin/bash script
#      1 a /usr/bin/perl script
#      1 a /bin/env -i /bin/bash script

#X Function: editorsyntaxstring
#X Usage   : editorsyntaxstring filetype filename
editorsyntaxstring() {
	local FileType="${1:-text}"
	local FileName="${2:-}"
	local editor
	editor="${3:-${EDITOR}}"
	local opt=''

	editor="$(basename "${editor%% *}")"

	# aggregate some filetypes	
	case "$FileType" in
		html)		FileType=php;;
		bash)		FileType=sh;;		
	esac

	case "$editor" in
		joe) 	[[ $FileType == 'text' ]] && FileType='sh'
					if [[ ! -f "/usr/share/joe/syntax/$FileType.jsf" ]]; then 
						echo >&2 "joe: Syntax file [$FileType].jsf not found for [$FileName]"
						FileType=text
						opt=''
					else
						opt="-syntax $FileType"			
					fi
					;;
		nano)
					opt-"--syntax=$FileType"
					;;
		*)
					msg.err "Editor [$editor] not found."
					;;
	esac
	echo $EDITOR $opt $FileName
}
declare -fx editorsyntaxstring

declare -Ax _ent_TextFileTypes=(	
			['ASCII text']='text'
			['Bourne-Again shell script']='bash'
			['XML 1.0 document']='xml'
			['HTML document']='html'
			['POSIX shell script']='sh'
			['PHP script']='php'
			['C source']='c'
			['SMTP mail']='smtp'
			['exported SGML document']='sgml'
			['Windows WIN.INI']='ini'
			['TeX document']='tex'
			['Python script']='python'
			['Non-ISO extended-ASCII text']='text'
			['Perl5 module source']='perl'
			['BSD makefile script']='bsdmake'
		)
textfiletype() {
	local testfile=''
	local -i typeonly=0
	local File='' FileType=text
	while (( $# )); do
		testfile="${1}"
		# for type only
		if [[ $testfile == '-t' ]]; then
			typeonly=1
			shift
			continue
		fi
#		[[ -d "$testfile" ]] && { shift; continue; }
		if [[ -f "$testfile" ]]; then
			# get file descriptions from file command		
			File=$(trim "$(file "$testfile" 2>/dev/null | grep ' text' | cut -d':' -f2)")
			[[ -z $File ]] && { shift; continue; }
			File=${File%%,*}
			[[ -z $File ]] && File='text'
			if [[ "${!_ent_TextFileTypes[@]}" == *"$File"* ]]; then
				FileType="${_ent_TextFileTypes[$File]}"
				[[ -z $FileType ]] && FileType='text'
			else
				h=$(head -n1 "$testfile")
				if 	 [[ $h =~ ^\#\!.*\/bash.* ]];	then	FileType='bash'
				elif [[ $h =~ ^\#\!.*\/sh.*   ]];	then	FileType='sh'
				elif [[ $h =~ ^\#\!.*\/php.*  \
									|| ${h:0:2} == '<?' ]];	then	FileType='php'
				fi
			fi
		fi
		
		# still equals text, so check file extension
		if [[ $FileType == '' || $FileType == 'text' ]]; then
			ext=${testfile##*\.}
			case "$ext" in
				php)				FileType=php;;
				htm|html)		FileType=html;;
				sh|conf)		FileType=sh;;
				bash|cnf)		FileType=bash;;
				c|h)				FileType=c;;
				xml)				FileType=xml;;
				''|*)				FileType=text;;
			esac
		fi
		
		((typeonly)) && echo "${FileType:-text}" \
				|| echo "${FileType}" "${testfile}"
		shift
	done
}
declare -fx textfiletype

#fin
