#!/bin/bash
#X Function	: urldecode
#X Desc			: URL-decode string 
#X Synopsis	: urldecode string
#X example  : for f in /opt/logs/*.log; do
#X          :   name=${f##/*/}
#X          :   cat $f | urldecode > /opt/logs/processed/$HOSTNAME.$name
#X          : done
urldecode() { echo -e "$(sed 's/+/ /g;s/%\(..\)/\\x\1/g;')"; }

declare -fx urldecode

#fin
