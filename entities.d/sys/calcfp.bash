#X Function: calcfp 
#X Desc    : Simple [bc] wrapper.
#X Synopsis: calcfp numericExpression
calcfp() { echo "$*" | bc -l; }
#fin

