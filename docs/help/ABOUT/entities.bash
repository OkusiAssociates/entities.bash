     About: entities.bash
      Desc: Entities Functions/Globals Declarations and Initialisations.
          : entities.bash is a light-weight Bash function library for systems
          : programmers and administrators.
          : 
          :   _ent_0       $PRGDIR/$PRG
          :   PRG          basename of current script.
          :   PRGDIR       directory location of current script, with
          :                symlinks resolved to actual location.
          :   _ent_LOADED  is set if entities.bash has been successfully
          :                loaded.
          : 
          : PRG/PRGDIR are *always* initialised as local vars regardless of
          : 'inherit' status when loading entities.bash.
          : 
   Depends: basename dirname readlink mkdir ln cat stty
       Url: file:///usr/share/okusi/entities/entities.bash
