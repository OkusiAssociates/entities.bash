#!/bin/bash
#X Global : _ent_VERSION
#X Version: 0.98.420.497.1
#X Desc   : Return version/build of this entities.bash.
#X        : Returns string in the form:
#X        :   majorver.minorver.420.day0.build
#X        : Where:
#X        :   majorver  1
#X        :   minorver  0
#X        :   420       Constant
#X        :   day0      Days since 2019-06-21 (497)
#X        :   build     This is build #1 on day 497
declare -xg _ent_VERSION
_ent_VERSION='0.98.420.497.1'
#fin
