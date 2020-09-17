#!/bin/bash
#X Global   : _ent_VERSION 
#X Desc     : Return version/build of this entities.bash.
#X          : Returns string in form:
#X          :   majorver.minorver.420.day0.daybuild
#X          : Where:
#X          :   majorver  1
#X          :   minorver  0
#X          :   420       constant
#X          :   day0      days since 2019-06-21 (454)
#X          :   daybuild  this is build number on day0 (16)
#X          : This entities.bash version is 0.95.420.454.16
declare -xg _ent_VERSION
_ent_VERSION='0.95.420.454.16'
#Xfin
