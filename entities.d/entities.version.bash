#!/bin/bash
#X Global: _ent_VERSION
#X Desc  : Return version/build of this entities.bash.
#X       : Returns string in form:
#X       :   majorver.minorver.420.day0.build
#X       : Where:
#X       :   majorver  1
#X       :   minorver  0
#X       :   420       constant
#X       :   day0      days since 2019-06-21 (484)
#X       :   build     this is build #23 on day 484
#X       : This is entities.bash version 0.98.420.484.23
declare -xg _ent_VERSION
_ent_VERSION='0.98.420.484.23'
#fin
