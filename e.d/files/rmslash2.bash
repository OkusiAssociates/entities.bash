#!/bin/bash
#! shellcheck disable=SC2154
#X Function: rmslash2
#X Desc    : Remove double slashes in filename
#X Usage   : rmslash string
#X Example : filename="//123/456///789/0"; rmslash2 "$filename" # returns /123/456/789/0
rmslash2() { echo "${@//+(\/)\//\/}"; }
declare -fx rmslash2
#fin
