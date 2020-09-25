##### Version [0.97.420.462.5]
# `entities.bash` Environment/Function Library

`entities.bash` is a lightweight Bash scripting environment and library for systems and network administrators who use `Ubuntu 18.04` or higher.

The basic philosophy is to be simple, unobtrusive and as flexible as possible, with minimal dependencies, while providing a standard functionality across an entire network environment.

#### `entities.bash` requires:

	* Ubuntu 18.04, or higher

#### Quick Install:

    sudo git clone https://github.com/OkusiAssociates/entities.bash.git && entities.bash/install.entities -y

#### Invocation

To invoke `entities`, just enter `source entitites` at the top of your script, or invoke it at the command line.
    
    source entities new
    msg "Hello World"
    entities help

Once loaded into the environment `entities` can be invoked without reloading the entire library.

If `entities` is already loaded at the time a script is run, it is not loaded again, greatly speeding up load and execution time for downstream scripts that also use `entities` library functions.

#### Functions

Here are some of the functions:

`addslashes` `ask.yn` `calcfp` `check.dependencies` `cleanup` `clntempfiles` `color` `color.set` `debug` `debug.set` `dequote` `dryrun` `dryrun.set` `editorsyntaxstring` `elipstr` `entities.location` `exit_if_already_running` `exit_if_not_root` `explode` `hr2int` `implode` `int2hr` `is.interactive` `is.number` `is.root` `is.tty` `ltrim` `mktempfile` `msg` `msg.crit` `msg.debug` `msg.die` `msg.err` `msg.info` `msg.line` `msg.prefix.separator.set` `msg.prefix.set` `msg.sys` `msg.warn` `onoff` `pause` `payload_decode` `payload_encode` `perrno` `post_slug` `remove_accents` `remsp2` `rtfm` `rtrim` `s` `slog` `slog.file` `slog.prefix` `slog.prefix.eval` `slog.truncate` `str_str` `strict` `strict.set` `tab.set` `tab.width` `textfiletype` `tmpdir.set` `trap.breakp` `trap.function` `trap.set` `trim` `urldecode` `urlencode` `urlpayload_encode` `verbose` `verbose.set` `version` `version.set`

`entities.bash` can be easily extended with new functions.

#### Scripts

##### Script   hashbang

###### Desc     

Search directory recursively for files with #!/bin/bash header.

###### Synopsis 

hashbang ["dir"] [--search "str"]  [-e|--exclude 'str'] [-p|--prefix "prefix"] [-x|--suffix "suffix"] 
 
###### Example
 
    # 0. print bash script filenames
    hashbang                   
    # 1. print bash filenames matching pattern
    hashbang . -s '^whereisit' 
    # 2. print bash filenames containing string 'varname'
    #    in format "p filename -s"
    hashbang . -s 'some_var_name' -p 'p' -x '-s' >editfiles

##### Script  : lsd

###### Desc

Wrapper script for 'tree'. Display directory tree starting at {pathspec}.

###### Synopsis lsd [-ls] [--levels num] [--treeopts...] [pathspec ...] 

If not specified, {pathspec} defaults to current directory.

##### Script  : p

###### Desc

Script programmers Edit/syntax-check/shellcheck wrapper for bash/php files. Bash/php scripts without .sh/.bash/php extentions are autodetected from the header. Uses envvar EDITOR

###### Synopsis p filename[{.sh,.bash,.php}] [-l|--line rownum] [-x]

##### Script  : sqlh

###### Desc

MySQL helper script to quickly view data/structure.

###### Synopsis sqlh [database [table [command]]] [-p profile] [-V] [-h]

###### Examples 
    0. sqlh         # direct to database selection
    1. sqlh Users   # open db Userss, then to table selection.
    2. sqlh Users users fields # open table Users:user and show fields. 
    3. sqlh -p /root/my3.cnf   # open mysql with profile. 

#### Help

See `entities help` for full documentation.

#### Developers

Are you a bash programmer? If you would like to assist with this project, go to the repository at:

    http://github.com/OkusiAssociates/entities.bash

For bugs/features/reports/requests, send to `garydean@linux.id`

