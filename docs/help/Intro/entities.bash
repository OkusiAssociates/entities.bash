#----Intro--entities.bash
     Intro: entities.bash
      Desc: Entities Functions/Globals/Local Declarations and Initialisations.
          : entities.bash is a light-weight Bash function library for systems
          : programmers and administrators.
          : __entities__ is set if entities.bash has been successfully loaded.
          : PRG=basename of current script.
          : PRGDIR=directory location of current script, with softlinks
          : resolved to actual location.
          : PRG/PRGDIR are *always* initialised as local vars regardless of
          : 'inherit' status when loading entities.bash.
   Depends: basename dirname readlink mkdir ln cat systemd-cat stty
    Source: /usr/share/okusi/entities/entities.bash
#----Intro--entities.bash-----------------------------------------------------
