#X Global   : _ent_VERSION 
#X Desc     : Return version/build of entities.bash.
#X          : Returns string in form of:
#X          :   majorver.minorver.420.day0.daybuild
#X          : where day0 is days since 2019-06-21
#X          :       daybuild is an incremental counter 
#X          :       of how many builds have been made on day0
declare -x _ent_VERSION='0.9.420.220.0'
