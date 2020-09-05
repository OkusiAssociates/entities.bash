/* header
header.c

Simple program that outputs all line from a file up to the first blank line.

Useful for extracting just the header portion of an email file.

Syntax: header {filename}

There are no options.
*/
#include <stdio.h>
#include <string.h>

void main(int argc, char* argv[]) {
    char s[102400];
    FILE *fp1;

	if(argc > 1) fp1 = fopen(argv[1], "r");
	else fp1=stdin;

	while((fgets(s, 102399, fp1)) != (char *)0 ) {
		if(s[strlen(s)-2]=='\r') continue; 
		if(s[0]=='\n') break; 
		if(s[0]==' ' || s[0] == '\t') {
			s[0]=' ';
			fseek(stdout, -1, SEEK_END);
		}
		fputs(s, stdout);
	}
	
	if(fp1 != stdin) fclose(fp1);
}

