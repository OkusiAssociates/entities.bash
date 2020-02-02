# Entities Function Library

Beta -- not production ready

Entities is a lightweight Bash scripting library for systems and network administrators.

To invoke Entities, just [source entitites.bash], at the top of your script, or at the command line.

If [entities.bash] is already loaded at the time a script is run, it is not loaded again, greatly speeding up load and execution time.

Some of the important functions and globals include:

  *  PRG		fq basename of current script name.
  *  PRGDIR	fq path for current script directory.
  
  * msg{.info|.err|.warn|.crit|.die} [log] message
  * ask.yn [prompt]
  * tab.set [++|--|numval]
  * tab.width [numval]
  * verbose.set [[on|1] | [off|0]]
  * color.set [[on|1] | [off|0]]
  * strict.set [[on|1] | [off|0*]]
  * trap.set [[on|1] | [off|0*]]
  * trap.function [function_name]
  * trim strval
  * rtrim strval
  * ltrim strval
  * exit_if_not_root
  * check.dependencies [program ...]
  * is_interactive

 Run [entities.help] for full documentation
