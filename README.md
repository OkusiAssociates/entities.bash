##### Version [0.97.420.461.13]
# `entities.bash` Environment and Function Library

`entities.bash` is a lightweight Bash scripting environment and library for systems and network administrators who use `Ubuntu 20.04` or higher.

The basic philosophy is to be simple, unobtrusive and as flexible as possible, with minimal dependencies, while providing standard funcionality across an environment.

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

Here are just a few of the functions and globals that I commonly use in my scripts:

  * `PRG`     # global var, fq basename of current script name.
  * `PRGDIR`  # global var, fq path for current script directory.
  * `msg{.info|.err|.warn|.crit|.die} [log] message`
  * `verbose.set [[on|1] | [off|0]]`
  * `color.set [[on|1] | [off|0]]`
  * `strict.set [[on|1] | [off|0]]`
  * `trap.set [[on|1] | [off|0]]`
  * `trim {strval}`

`entities.bash` can be easily extended with new functions.

See `entities help` for full documentation.

#### Developers

Are you a bash programmer? If you would like to assist with this project, go to the repository at:

    http://github.com/OkusiAssociates/entities.bash


