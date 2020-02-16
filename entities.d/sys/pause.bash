#!/bin/bash
pause() { read -n1 -p "${1:-*Pause*}"; echo; }
declare -fx pause
