#!/bin/bash
#! shellcheck disable=SC1072

#X    Script:  entities.scripts.create-help
#X   Version:  entities 0.98.420.487.7
#X      Desc:  For developers of entities.bash functions and scripts.
#X          :  Assists the entities help system gather documentation.
#X          :  All scripts in the entities/scripts directory must be 
#X          :  mode executable, with no .bash extension,
#X          :  Scripts must respond to a -h|--help option, output help
#X          :  in entities.bash standard format.
#X  Synopsis:  entities.scripts.create-help [-y] [-o [output]] [-V] [-h]
#X          :    -y|--no-prompt      Do not prompt to ask before execution.
#X          :    -o|--output output  Change default output. 
#X          :                        Default is 'scripts.help.bash'
#X          :    -V|--version        Print version.
#X          :    -h|--help           This help.

#X    Script:  dbh
#X   Version:  entities.bash 0.98.420.487.7
#X      Desc:  MySQL helper script to quickly view data/structure/info.
#X          :  Fast in, fast out.
#X  Synopsis:  dbh [database [table [command]]] [-p profile] [-V] [-h]
#X          :    database      Database name.
#X          :    table         Table name.
#X          :    command       Valid commands are:
#X          :                    columns
#X          :                    select_fields 
#X          :                    sql_command 
#X          :                    sql_prompt 
#X          :                    structure
#X          :    -p|--profile  Specify MySQL profile [eg, /root/.my3.cnf].
#X          :    -x|--exit     Exit after executing command (if specified).
#X          :    -V|--version  Print version.
#X          :    -h|--help     This help.
#X          :  To back out of a menu, select 0. To exit, select q.
#X          : 
#X  Examples:  # 0. go direct to database selection menu.
#X          :  dbh
#X          : 
#X          :  # 1. open db Users, then to table selection.
#X          :  dbh Users
#X          : 
#X          :  # 2. open table Users:user and show column names.
#X          :  dbh Users users columns 
#X          : 
#X          :  # 3. open mysql with profile, open Essays:essays 
#X          :  dbh -p /root/my3.cnf Essays essays

#X    Script:  findrecent
#X      Desc:  Find 'n' most recently updated files in directory.
#X  Synopsis:  findrecent [-n num] [-p "dir"][-N] ["dir"]
#X          :    dir        Directory spec. Default '.'
#X          :    -n|--headnum num  
#X          :               Number of files to display. Default 10
#X          :    -p|--prune "dir"
#X          :               Add dir to hb_PRUNE. Enable Prune.
#X          :    -N|--no-prune
#X          :               Clear hb_PRUNE. Disable Prune.
#X          :  Prune is enabled by default.
#X          :  Current hb_PRUNE value is:
#X          :    ( ~* *~ *gudang *.gudang *.old *.bak *dev *help *cctv *.git git )
#X          : 
#X   Example:  findrecent /var/www -n 15
#X          : 
#X          :  findrecent /internet -N -p '*KLIEN'

#X    Script:  archivedir 
#X      Desc:  Create zip archive of a directory, and store in directory 
#X          :  called [.]{DirNameBase}.old.  Multiple snap-shots of directores
#X          :  can be maintained, with option to prune oldest files.    
#X          :  The zip archive name uses the format {archiveName}.{time}.old
#X  Synopsis:  archivedir "dirname" [-H] [-l] [-P [limit]]  [-v][-q] [-V] [-h]
#X          :   -H|--hidden   Create archive directory as hidden (prefix '.')
#X          :                 Once created as hidden, -H must always be used to
#X          :                 add new archives.
#X          :   -l|--list     List all files in the 'dirname.old' archive directory.
#X          :   -P|--prune limit  
#X          :                 Specify max number of archive files allowed, in
#X          :                 archive directory, and delete oldest if necessary.      
#X          :   -v|--verbose  Turn on  msg verbose. (default)
#X          :   -q|--quiet    Turn off msg verbose.
#X          :   -V|--version  Print version.
#X          :   -h|--help     This help.
#X  Examples: 
#X          :  # 0. creates dir /usr/share/usr/.myscripts.old (if it doesn't exist)
#X          :  #    then makes a zip archive called myscripts.1561065600.zip.
#X          :  #    -H creates the .old directory as 'hidden', with a leading dot.
#X          :  archivedir /usr/share/myscripts -H -l 15 
#X          : 
#X          :  # 1. just make an archive of a directory
#X          :  #    Zip file would be located in directory myscripts.old.
#X          :  archivedir myscripts

#X    Script:  p
#X      Desc:  Edit/SyntaxCheck/ShellCheck/Execute for 
#X          :  bash and php scripts.
#X          :  Bash/php scripts without .sh/.bash/.php extensions 
#X          :  are autodetected from the header.
#X          :  Uses envvar EDITOR ([/usr/bin/joe -tab 2 -autoindent --wordwrap])
#X  Synopsis:  p filename [-l row] [-s] [-x]
#X          :    -l row  position at row on entry to editor.
#X          :    -s      execute shellcheck after editing.
#X          :    +s      don't execute shellcheck after editing (default).
#X          :    -x      execute script after editing (asks first).
#X          :    +x      don't execute script after editing (default).
#X  Requires:  shellcheck

#X    Script:  lsd
#X   Version:  0.97
#X      Desc:  Display directory tree. Wrapper script for 'tree'. 
#X  Synopsis:  lsd [-ls] [-L num] [-n][-C] [pathspec ...] [-- ...]  
#X          :  pathspec       If not specified, {pathspec} defaults to 
#X          :                 current directory.
#X          :   -L num        Traverse maximum num levels. Def. 1, 0=255.
#X          :   --ls          Output file with 'ls' type listing.
#X          :   -n|--nocolor  Don't use color.
#X          :   -C|--color    Use color. (Default if terminal.)
#X          :   --            Rest of arguments/options pass to 'tree'.
#X          :                 (See 'tree --help' for additional options.)
#X          :   -V|--version  Print version information.
#X          :   -h|--help     Help.
#X   Depends:  tree

#X    Script:  hashbang
#X   Version:  0.97
#X      Desc:  Use 'find' and 'grep' to search directory recursively for files 
#X          :  identified as bash scripts, ignoring all other files. 
#X          :  Identification is by filename extension, a hashbang 
#X          :  containing '/bash', or by result from 'file' command.
#X  Synopsis:  hashbang ["dir"] [-s str] [-b php|php] [-X][-Y][-e]
#X          :           [-p str][-x str][-f str] [-l] [-v][-q] [--] 
#X          :    dir                    Directory to start search (def. '.')
#X          :    -s|--search "str"      String to find in found files.
#X          :    -b|--hashbang bash|php File type to search (def. bash)
#X          :    -X|--hb-exclude        Exclude using envvar hb_EXCLUDE (default).
#X          :    -Y|--no-hb-exclude     Do not use hb-exclude.
#X          :    -e|--exclude 'expr'    Add 'expr' to hb_EXCLUDE. Enables -X; 
#X          :                           re-disable with -Y.
#X          :    -f|--padfix "str"      Spacer for pre/suffix (def. ' '). 
#X          :                           For no spacer: -f ''
#X          :    -p|--prefix "prefix"   Prefix found files with "prefix".
#X          :    -x|--suffix "suffix"   Suffix found files with "suffix".
#X          :    -l|--nolf              No line feed at end of filename.
#X          :    -v|--verbose           Verbose (default). Enable messages.
#X          :    -D|--debug             Increase verbosity. Enables -v.
#X          :    -q|--quiet             No messages. Disables -v -D.
#X          :    --|--grep              Pass remaining parameters to grep.
#X          :  Note: All non-hashbang options are passed onto grep.
#X          : 
#X   Example:  # 0. recursively identitfy all bash scripts in /usr/bin.
#X          :  hashbang /usr/bin
#X          :  
#X          :  # 1. print bash filenames for string matching pattern
#X          :  hashbang -s '^whereisit' 
#X          :  
#X          :  # 2. print bash filenames containing string 'varname' in format 
#X          :  #    "p {filename} -s". Useful for generating temporary scripts.
#X          :  #    In this case, I wish to edit {filename} (using the entities 
#X          :  #    'p' editor) with shellcheck enabled.
#X          :  hashbang -s 'some_var_name' -p 'p' -x '-s' >editfiles

#X    Script:  cln
#X   Version:  entities 0.98.420.487.7
#X      Desc:  Search for and delete defined junk/trash/rubbish files.
#X  Synopsis:  cln [-m depth] [-n][-N] [-v][-q] [dirspec ...]
#X          :    dirspec           Path to clean. Default '.'
#X          :    -a|-add file      Add file to cleanup scan. Can be used 
#X          :                      multiple times, and filesname can comma
#X          :                      delimited.
#X          :    -m|--depth depth  Maximum depth to recurse. Default 2.
#X          :    -n|--dryrun       Dry run. Default on.
#X          :    -N|--notdryrun    Not a dry run. Delete files straight away.
#X          :    -v|--verbose      Enable output to stdout. Default on.
#X          :    -q|--quiet        Disable output to stdout.
#X          :    -h|--help         This help.
#X          :  Recursively remove all temporary files defined in 
#X          :  envvar _ent_CLNTEMP that defines temporary files to delete.
#X          :  If not defined, _ent_CLNTEMP defaults to:
#X          :    ( '*~' '~*' '.~*' '.*~' )
#X          :  _ent_CLNTEMP is currently set to:
#X          :    ( *~ ~* .~* .*~ DEADJOE dead.letter wget-log* )


