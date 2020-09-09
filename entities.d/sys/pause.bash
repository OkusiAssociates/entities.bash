#!/bin/bash
#X Function: pause
#X Desc    : wait for one keypress
pause() { read -n1 -p "${1:-*Pause*}"; echo; }
declare -fx pause
