#X Function: calcfp 
#X Usage: calcfp <numericExpression>
calcfp() { echo "$*" | bc -l; }

