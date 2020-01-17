#----Intro--entities.bash
     Intro: entities.bash
      Desc: Entities Functions/Globals/Locals Declarations and Initialisations.
          : entities.bash is a light-weight function library for productive
          : programmers and administrators. - the soft machine
          : PRG=basename of current script.
          : PRGDIR=directory location of current script, with softlinks
          : resolved to actual location.
          : PRG/PRGDIR are *always* initialised as local vars regardless of
          : 'preserve' status when loading entities.bash.
  Synopsis: source entities.bash [ [preserve*] | [new] | [load libname]
          :                       | [no-load libname] | [load-to newdir] ]
          : source entities.bash preserve
          :       # ^ if entities.bash has already been loaded,
          :       # init PRGDIR/PRG globals only then return.
          :       # if entities.bash has not been loaded, load it.
          :       # [preserve] is the default.
          : source entities.bash new
          :       # ^ load new instance of entities.bash;
          :       # do not use any existing instance already loaded.
          : source entities.bash load libname
          :       # ^ load an additional library of bash scripts
          : source entities.bash no-load libname
          :       # ^ infers new, libname is not loaded with entities.bash
          : source entities.bash load-to newdir
          :       # ^ load into new dir (eg, /run/entities) and
          :       # set ENTITIES globalvar to new position.
   Depends: basename dirname readlink mkdir ln cat systemd-cat printf stty
#----Intro--entities.bash-----------------------------------------------------
