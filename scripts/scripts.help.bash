#!/bin/bash
#X Script  : dbh
#X Version : 0.98
#X Desc    : MySQL helper script to quickly view data/structure/info,
#X : without a lot of typing long sql commands. Fast in, fast out.
#X Synopsis: dbh [database [table [command]]] [-p profile] [-V] [-h]
#X :   -p|--profile  Specify mysql profile [eg, /root/.my3.cnf].
#X :   -V|--version  Print version.
#X :   -h|--help     This help.
#X : To back out of a menu, select 0.
#X : To exit, select q.
#X Examples: # 0. go direct to database selection menu.
#X : dbh
#X : # 1. open db Users, then to table selection.
#X : dbh Users
#X : # 2. open table Users:user and show fields.
#X : dbh Users users fields
#X : # 3. open mysql with profile, open Essays:essays
#X : dbh -p /root/my3.cnf Essays essays

#X Script  : archivedir
#X Desc    : Create zip archive of a directory, and store in directory
#X : called [.]{DirNameBase}.old.  Multiple snap-shots of directores
#X : can be maintained, with option to prune oldest files.
#X : The zip archive name uses the format {archiveName}.{time}.old
#X Synopsis: archivedir dirname [-l limit] [-H] [-v][-q] [-V] [-h]
#X :  -P|--prune    Specify max number of archive files allowed, in
#X :                archive directory, and delete oldest if necessary.
#X :  -H|--hidden   Create archive directory as hidden (prefix '.')
#X :                Once created as hidden, -H must always be used to
#X :                add new archives to the archive directory.
#X :  -v|--verbose  turn on  msg verbose. (default)
#X :  -q|--quiet    turn off msg verbose.
#X :  -V|--version  print version.
#X :  -h|--help     this help.
#X Example : # 0. creates dir /usr/share/usr/.myscripts.old (if it doesn't exist)
#X : #    then makes a zip archive called myscripts.1561065600.zip.
#X : #    -H creates the .old directory as 'hidden', with a leading dot.
#X : archivedir /usr/share/myscripts -H -l 15
#X : # 1. just archive a directory
#X : archivedir myscripts

#X Script  : p
#X Desc    : Edit/SyntaxCheck/ShellCheck/Execute for
#X : bash and php scripts.
#X : Bash/php scripts without .sh/.bash/.php extensions
#X : are autodetected from the header.
#X : Uses envvar EDITOR ([/usr/bin/joe -tab 2 -autoindent --wordwrap])
#X Synopsis: p filename [-l row] [-s] [-x]
#X :   -l row  position at row on entry to editor.
#X :   -s      execute shellcheck after editing.
#X :   +s      don't execute shellcheck after editing (default).
#X :   -x      execute script after editing (asks first).
#X :   +x      don't execute script after editing (default).
#X Requires: shellcheck

#X Script  : lsd
#X Version : 0.97
#X Desc    : Display directory tree. Wrapper script for 'tree'.
#X Synopsis: lsd [-ls] [-L num] [-n][-C] [pathspec ...] [-- ...]
#X : pathspec       If not specified, {pathspec} defaults to
#X :                current directory.
#X :  -L num        Traverse maximum num levels. Def. 1, 0=255.
#X :  --ls          Output file with 'ls' type listing.
#X :  -n|--nocolor  Don't use color.
#X :  -C|--color    Use color. (Default if terminal.)
#X :  --            Rest of arguments/options pass to 'tree'.
#X :                (See 'tree --help' for additional options.)
#X :  -V|--version  Print version information.
#X :  -h|--help     Help.
#X Depends : tree

#X Script  : hashbang
#X Version : 0.97
#X Desc    : Use 'find' and 'grep' to search directory recursively for
#X : files identified as bash scripts, ignoring all other files.
#X : Identification is by filename extension, a hashbang
#X : containing '/bash', or by result from 'file' command.
#X Synopsis: hashbang ["dir"] [-s str] [-b php|php] [-X][-Y][-e]
#X :          [-p str][-x str][-f str] [-l] [-v][-q] [--]
#X :   dir                    Directory to start search (def. '.')
#X :   -s|--search "str"      String to find in found files.
#X :   -b|--hashbang bash|php File type to search (def. bash)
#X :   -X|--hb-exclude        Exclude using envvar hb_EXCLUDE.
#X :   -Y|--no-hb-exclude     Do not use hb-exclude.
#X :   -e|--exclude 'expr'    Add 'expr' to hb_EXCLUDE. Enables -X;
#X :                          re-disable with -Y.
#X :   -f|--padfix "str"      Spacer for pre/suffix (def. ' ').
#X :                          For no spacer: -f ''
#X :   -p|--prefix "prefix"   Prefix found files with "prefix".
#X :   -x|--suffix "suffix"   Suffix found files with "suffix".
#X :   -l|--nolf              No line feed at end of filename.
#X :   -v|--verbose           Verbose (default). Enable messages.
#X :   -D|--debug             Increase verbosity. Enables -v.
#X :   -q|--quiet             No messages. Disables -v -D.
#X :   --|--grep              Pass remaining parameters to grep.
#X : Note: All non-hashbang options are passed onto grep.
#X Example: # 0. recursively find all qualified bash script filenames
#X : hashbang
#X :
#X : # 1. print bash filenames for string matching pattern
#X : hashbang -s '^whereisit'
#X :
#X : # 2. print bash filenames containing string 'varname' in format
#X : #    "p {filename} -s". Useful for generating temporary scripts.
#X : #    In this case, I wish to edit {filename} (using the entities
#X : #    'p' editor) with shellcheck enabled.
#X : hashbang -s 'some_var_name' -p 'p' -x '-s' >editfiles

#X Script  : cln
#X Desc    : Search for and delete defined rubbish files.
#X Synopsis: cln [-m depth] [-n][-N] [-v][-q] [dirspec ...]
#X :   dirspec           Default '.'
#X :   -a|-add file      Add file to cleanup scan. Can be used
#X :                     multiple times.
#X :   -m|--depth depth  Maximum depth to recurse. Default 2.
#X :   -n|--dryrun       Dry run. Default on.
#X :   -N|--notdryrun    Not a dry run. Delete files straight away.
#X :   -v|--verbose      Enable output to stdout. Default on.
#X :   -q|--quiet        Disable output to stdout.
#X :   -h|--help         This help.
#X : Recursively remove all temporary files defined in
#X : Array envvar _ent_CLNTEMP defines temporary files to delete.
#X : If not set, defaults to ( '*~' '~*' '.~*' )
#X : _ent_CLNTEMP currently set to:
#X :   ( *~ ~* .~* DEADJOE dead.letter )
#X : If not defined, _ent_CLNTEMP defaults to ( '*~' '~*' '.~*' )


