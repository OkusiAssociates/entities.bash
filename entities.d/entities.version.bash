#!/bin/bash
#X Global: _ent_VERSION
#X Desc  : Return version/build of this entities.bash.
#X       : Returns string in form:
#X       :   majorver.minorver.420.day0.build
#X       : Where:
#X       :   majorver  1
#X       :   minorver  0
#X       :   420       constant
#X       :   day0      days since 2019-06-21 (465)
#X       :   build     this is build #6 on day 465
#X       : This is entities.bash version 0.97.420.465.6
declare -xg _ent_VERSION
_ent_VERSION='0.97.420.465.6'
#fin
