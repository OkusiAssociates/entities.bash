#X Function: s
#X Desc    : Print 's' if number is not 1.
#X Synopsis: s number
#X         :
#X Example : num=30; echo "$num file$(s $num) counted."
#X         : num=1; echo "$num file$(s $num) counted."
s() {	(( ${1:-1} == 1 )) || echo -n 's'; }
declare -fx s
#fin
