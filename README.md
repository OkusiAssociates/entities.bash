# Entities Function Library

Entities is a lightweight Bash scripting library for systems and network administrators.

The basic philosophy is to be simple, unobtrusive and as flexible as possible, with minimal dependencies.

To invoke Entities, just put [source entitites] at the top of your script, or invoke it at the command line.

Once loaded into the environment [entities] can be invoked without reloading the entire library.

If [entities] is already loaded at the time a script is run, it is not loaded again, greatly speeding up load and execution time for downstream scripts that also use entities library functions.

Here is a some of the functions and globals that I use in my scripts:

  *  PRG		local var, fq basename of current script name.
  *  PRGDIR	local var, fq path for current script directory.
  
  * msg{.info|.err|.warn|.crit|.die} [log] message
  * ask.yn [prompt]
  * tab.set [++|--|numval]
  * tab.width [numval]
  * verbose.set [[on|1] | [off|0]]
  * color.set [[on|1] | [off|0]]
  * strict.set [[on|1] | [off|0]]
  * trap.set [[on|1] | [off|0]]
  * trap.function [function_name]
  * trim {strval}
  * rtrim {strval}
  * ltrim {strval}

[entities] can be easily extended with new functions.

Run [entities.help] for full documentation

