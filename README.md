##### Version [0.98.420.487.9]
# Entities.bash Environment/Function Library
###### Version [$_ent_VERSION]

Entities.bash is a lightweight Bash scripting environment and library for systems and network administrators who use `Ubuntu 18.04` or higher.

The philosophy is to be simple, unobtrusive, flexible, with minimal dependencies, while providing a standard functionality across an entire network environment.

### Entities.bash requires:

* Ubuntu 18.04, or higher
* Bash 4.4, or higher

Use on non-Ubuntu systems should be possible with minimal changes.  

### Quick Install:

    sudo git clone https://github.com/OkusiAssociates/entities.bash.git && entities.bash/entities.install -y

### Invocation

To invoke `entities`, just enter `source entitites` at the top of your script, or invoke it at the command line.
````
    source entities new
    msg "Hello World"
    entities help
````
Once loaded into the environment `entities` can be invoked without reloading the entire library.

If `entities` is already loaded at the time a script is run, it is not loaded again, greatly speeding up load and execution time for downstream scripts that also use `entities` library functions.

### Functions

Current functions:

`addslashes  ` `breakp  ` `calcfp  ` `check.dependencies  ` `chgConfigVar  ` `cleanup  ` `color  ` `color.set  ` `convertCfg2php  ` `debug  ` `debug.set  ` `dqslash  ` `dryrun  ` `dryrun.set  ` `editorsyntaxstring  ` `elipstr  ` `entities.help  ` `entities.location  ` `etx` `exit_if_already_running  ` `exit_if_not_root  ` `explode  ` `hr2int  ` `implode  ` `in_array  ` `int2hr  ` `is.color  ` `is.debug  ` `is.dryrun  ` `is.int  ` `is_interactive  ` `is.interactive  ` `is.number  ` `is.root  ` `is.strict  ` `is_tty  ` `is.tty  ` `is.verbose  ` `ltrim  ` `mktempfile  ` `msg  ` `msg.alert  ` `msg.color  ` `msg.color.set  ` `msg.crit  ` `msg.debug  ` `msg.die  ` `msg.emerg  ` `msg.err  ` `msg.info  ` `msg.line  ` `msgline  ` `msg.notice  ` `msg.prefix.separator.set  ` `msg.prefix.set  ` `msg.sys  ` `msg.tab.set  ` `msg.tab.width  ` `msg.usetag.set  ` `msg.verbose  ` `msg.verbose.set  ` `msg.warn  ` `msg.warning  ` `msgx  ` `msg.yn  ` `onoff  ` `pause  ` `payload_decode  ` `payload_encode  ` `perrno  ` `phpini_short_tags  ` `post_slug  ` `remove_accents  ` `remsp2  ` `rmslash2  ` `rtfm  ` `rtrim  ` `s  ` `sqslash  ` `strict.set  ` `str_str  ` `tab.set  ` `tab.width  ` `textfiletype  ` `titlecase  ` `tmpdir.set  ` `trap.breakp  ` `trap.function  ` `trap.set  ` `trim  ` `urldecode  ` `urlencode  ` `urlpayload_encode  ` `verbose.set  ` `version  ` `version.set  ` `website_online  ` 
### Script/Function Templates

Scripting templates are an important part of a programmer's armory.  `entitities.bash` comes with several simple but powerful templates for new scripts, or functions.  Here are the ones used most frequently:

#### Template `new.function.template.bash`
````
#!/bin/bash
#X Script:Function:GlobalX:Global:Local: 
#X Desc    : 
#X Synopsis: 
#X Examples: 
#X See Also:
X() {
  
  
  
  return 0  
}
#fin
````

#### Template `new.script.template.bash`
````
#!/bin/bash
# #! shellcheck disable=SC
source entities || exit 2
  trap.set on
  strict.set on
  version.set '0.1'
  msg.prefix.set "$PRG"
  
  # global vars
  
  
# main
main() {
  local -a args=()
  while (( $# )); do
    case "$1" in
      #-|--);;
      -v|--verbose)   msg.verbose.set on;;
      -q|--quiet)     msg.verbose.set off;;
      -V|--version)   version.set; return 0;;
      -h|--help)      usage; return 0;;
      -?|--*)         msg.err "Invalid option [$1]"; return 22;;
      *)              args+=( "$1" );;
                      #msg.err "Invalid argument [$1]"; return 22;;
    esac
    shift
  done

  # code
  msg "${args[@]:-}"
  
  
  
}

# exit trap set to cleanup
# shellcheck disable=SC2086
cleanup() {
  local -i err=$?
  [[ -z ${1:-} ]] && err=$1
  #...
  ((err > 1)) && errno $err
  exit $err
}

usage() {
# 0#######:#|##|############|#################################################78
  cat <<-etx
  Script  : 
  Desc    : 
  Synopsis: $PRG    [-v][-q] [-V] [-h]
          :  -|--           
          :  -|--           
          :  -v|--verbose   Turn on msg verbose. (default)
          :  -q|--quiet     Turn off msg verbose.
          :  -V|--version   Print version.
          :  -h|--help      This help.
  Example : 
  etx
# 0#######:#|##|############|#################################################78
  return 0
}

main "$@"
#fin
````

### Scripts

#### Script `archivedir`
````
Script  : archivedir 
Desc    : Create zip archive of a directory, and store in directory 
        : called [.]{DirNameBase}.old.  Multiple snap-shots of directores
        : can be maintained, with option to prune oldest files.    
        : The zip archive name uses the format {archiveName}.{time}.old
Synopsis: archivedir "dirname" [-H] [-l] [-P [limit]]  [-v][-q] [-V] [-h]
        :  -H|--hidden   Create archive directory as hidden (prefix '.')
        :                Once created as hidden, -H must always be used to
        :                add new archives.
        :  -l|--list     List all files in the 'dirname.old' archive directory.
        :  -P|--prune limit  
        :                Specify max number of archive files allowed, in
        :                archive directory, and delete oldest if necessary.      
        :  -v|--verbose  Turn on  msg verbose. (default)
        :  -q|--quiet    Turn off msg verbose.
        :  -V|--version  Print version.
        :  -h|--help     This help.
Examples:
        : # 0. creates dir /usr/share/usr/.myscripts.old (if it doesn't exist)
        : #    then makes a zip archive called myscripts.1561065600.zip.
        : #    -H creates the .old directory as 'hidden', with a leading dot.
        : archivedir /usr/share/myscripts -H -l 15 
        :
        : # 1. just make an archive of a directory
        : #    Zip file would be located in directory myscripts.old.
        : archivedir myscripts
````

#### Script `cln`
````
Script  : cln
Version : entities 0.98.420.487.8
Desc    : Search for and delete defined junk/trash/rubbish files.
Synopsis: cln [-m depth] [-n][-N] [-v][-q] [dirspec ...]
        :   dirspec           Path to clean. Default '.'
        :   -a|-add file      Add file to cleanup scan. Can be used 
        :                     multiple times, and filesname can comma
        :                     delimited.
        :   -m|--depth depth  Maximum depth to recurse. Default 2.
        :   -n|--dryrun       Dry run. Default on.
        :   -N|--notdryrun    Not a dry run. Delete files straight away.
        :   -v|--verbose      Enable output to stdout. Default on.
        :   -q|--quiet        Disable output to stdout.
        :   -h|--help         This help.
        : Recursively remove all temporary files defined in 
        : envvar _ent_CLNTEMP that defines temporary files to delete.
        : If not defined, _ent_CLNTEMP defaults to:
        :   ( '*~' '~*' '.~*' '.*~' )
        : _ent_CLNTEMP is currently set to:
        :   ( *~ ~* .~* .*~ DEADJOE dead.letter wget-log* )
````

#### Script `dbh`
````
Script  : dbh
Version : entities.bash 0.98.420.487.8
Desc    : MySQL helper script to quickly view data/structure/info.
        : Fast in, fast out.
Synopsis: dbh [database [table [command]]] [-p profile] [-V] [-h]
        :   database      Database name.
        :   table         Table name.
        :   command       Valid commands are:
        :                   columns
        :                   select_fields 
        :                   sql_command 
        :                   sql_prompt 
        :                   structure
        :   -p|--profile  Specify MySQL profile [eg, /root/.my3.cnf].
        :   -x|--exit     Exit after executing command (if specified).
        :   -V|--version  Print version.
        :   -h|--help     This help.
        : To back out of a menu, select 0. To exit, select q.
        :
Examples: # 0. go direct to database selection menu.
        : dbh
        :
        : # 1. open db Users, then to table selection.
        : dbh Users
        :
        : # 2. open table Users:user and show column names.
        : dbh Users users columns 
        :
        : # 3. open mysql with profile, open Essays:essays 
        : dbh -p /root/my3.cnf Essays essays
````

#### Script `test-script`
````
grep: /usr/share/okusi/entities/scripts/entities.bash: No such file or directory
````

#### Script `launch`
````
/usr/share/okusi/entities/scripts/dev/tsr/launch: line 11: tabset: command not found
````

#### Script `shell1`
````
source: source filename [arguments]
    Execute commands from a file in the current shell.
    
    Read and execute commands from FILENAME in the current shell.  The
    entries in $PATH are used to find the directory containing FILENAME.
    If any ARGUMENTS are supplied, they become the positional parameters
    when FILENAME is executed.
    
    Exit Status:
    Returns the status of the last command executed in FILENAME; fails if
    FILENAME cannot be read.
````

#### Script `shell2`
````
source: source filename [arguments]
    Execute commands from a file in the current shell.
    
    Read and execute commands from FILENAME in the current shell.  The
    entries in $PATH are used to find the directory containing FILENAME.
    If any ARGUMENTS are supplied, they become the positional parameters
    when FILENAME is executed.
    
    Exit Status:
    Returns the status of the last command executed in FILENAME; fails if
    FILENAME cannot be read.
````

#### Script `shell3`
````
[3gH    H    H    H    H    H    H    H    H    H    H    H    H    H    H    H    H    H    H    H    H    H    H    H    H    H    H    H    H    H    H    H    H  ````

#### Script `findrecent`
````
Script  : findrecent
Desc    : Find 'n' most recently updated files in directory.
Synopsis: findrecent [-n num] [-p "dir"][-N] ["dir"]
        :   dir        Directory spec. Default '.'
        :   -n|--headnum num  
        :              Number of files to display. Default 10
        :   -p|--prune "dir"
        :              Add dir to hb_PRUNE. Enable Prune.
        :   -N|--no-prune
        :              Clear hb_PRUNE. Disable Prune.
        : Prune is enabled by default.
        : Current hb_PRUNE value is:
        :   ( ~* *~ *gudang *.gudang *.old *.bak *dev *help *cctv *.git git )
        :
Example : findrecent /var/www -n 15
        :
        : findrecent /internet -N -p '*KLIEN'
````

#### Script `hashbang`
````
Script  : hashbang
Version : 0.97
Desc    : Use 'find' and 'grep' to search directory recursively for files 
        : identified as bash scripts, ignoring all other files. 
        : Identification is by filename extension, a hashbang 
        : containing '/bash', or by result from 'file' command.
Synopsis: hashbang ["dir"] [-s str] [-b php|php] [-X][-Y][-e]
        :          [-p str][-x str][-f str] [-l] [-v][-q] [--] 
        :   dir                    Directory to start search (def. '.')
        :   -s|--search "str"      String to find in found files.
        :   -b|--hashbang bash|php File type to search (def. bash)
        :   -X|--hb-exclude        Exclude using envvar hb_EXCLUDE (default).
        :   -Y|--no-hb-exclude     Do not use hb-exclude.
        :   -e|--exclude 'expr'    Add 'expr' to hb_EXCLUDE. Enables -X; 
        :                          re-disable with -Y.
        :   -f|--padfix "str"      Spacer for pre/suffix (def. ' '). 
        :                          For no spacer: -f ''
        :   -p|--prefix "prefix"   Prefix found files with "prefix".
        :   -x|--suffix "suffix"   Suffix found files with "suffix".
        :   -l|--nolf              No line feed at end of filename.
        :   -v|--verbose           Verbose (default). Enable messages.
        :   -D|--debug             Increase verbosity. Enables -v.
        :   -q|--quiet             No messages. Disables -v -D.
        :   --|--grep              Pass remaining parameters to grep.
        : Note: All non-hashbang options are passed onto grep.
        :
 Example: # 0. recursively identitfy all bash scripts in /usr/bin.
        : hashbang /usr/bin
        : 
        : # 1. print bash filenames for string matching pattern
        : hashbang -s '^whereisit' 
        : 
        : # 2. print bash filenames containing string 'varname' in format 
        : #    "p {filename} -s". Useful for generating temporary scripts.
        : #    In this case, I wish to edit {filename} (using the entities 
        : #    'p' editor) with shellcheck enabled.
        : hashbang -s 'some_var_name' -p 'p' -x '-s' >editfiles
````

#### Script `lsd`
````
Script  : lsd
Version : 0.97
Desc    : Display directory tree. Wrapper script for 'tree'. 
Synopsis: lsd [-ls] [-L num] [-n][-C] [pathspec ...] [-- ...]  
        : pathspec       If not specified, {pathspec} defaults to 
        :                current directory.
        :  -L num        Traverse maximum num levels. Def. 1, 0=255.
        :  --ls          Output file with 'ls' type listing.
        :  -n|--nocolor  Don't use color.
        :  -C|--color    Use color. (Default if terminal.)
        :  --            Rest of arguments/options pass to 'tree'.
        :                (See 'tree --help' for additional options.)
        :  -V|--version  Print version information.
        :  -h|--help     Help.
Depends : tree
````

#### Script `p`
````
Script  : p
Desc    : Edit/SyntaxCheck/ShellCheck/Execute for 
        : bash and php scripts.
        : Bash/php scripts without .sh/.bash/.php extensions 
        : are autodetected from the header.
        : Uses envvar EDITOR ([/usr/bin/joe -tab 2 -autoindent --wordwrap])
Synopsis: p filename [-l row] [-s] [-x]
        :   -l row  position at row on entry to editor.
        :   -s      execute shellcheck after editing.
        :   +s      don't execute shellcheck after editing (default).
        :   -x      execute script after editing (asks first).
        :   +x      don't execute script after editing (default).
Requires: shellcheck
````

### Help

See `entities help` for full documentation.

### Developers

Are you a bash programmer? If you would like to assist with this project, go to the repository at:

    http://github.com/OkusiAssociates/entities.bash

Bugs/Features/Reports/Requests/Criticism send to `garydean@linux.id`

