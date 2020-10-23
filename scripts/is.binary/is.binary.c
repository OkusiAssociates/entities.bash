/* mailhead
#X Function: is.binary
#X Desc    : Examine *first 24 chars* of file for binary chars.  
#X         : Return true if found.  
#X         : Return 255 if file not found.
#X         : 'Binary chars' are defined as follows:
#X         :    >=127 <9 (<32 && >13)
#X         :
#X Synopsis: is.binary [filename]
#X         :   filename  File to examine. Default is stdin.
#X         :
#X Example : is.binary /bin/bash && echo 'Is binary!'
#X         :  
#X See Also: is.binary.c
gcc is.binary.c -o is.binary
*/
#include <stdio.h>

#define MAXSAMP 24

int main(int argc, char* argv[]) {
  FILE *fp1;
  int i=MAXSAMP;
  int binflag=0;
  unsigned int c;
  
  if(argc > 1) {
    fp1 = fopen(argv[1], "r");
    if(fp1 == NULL) {
//      perror("is.binary: ");
      return(-1);
    }
  } else fp1=stdin;
  
  while(i--) {
    if(feof(fp1)) break;
    c = fgetc(fp1);
    if(c>=127 || c<9 || (c<32 && c>13) ) { binflag=1; break; } 
  }
  
  if(fp1 != stdin) fclose(fp1);
  return(!binflag);
}
/*fin*/
