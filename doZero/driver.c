#include <stdio.h>
#include <stdlib.h>
#include "tiger.tab.h"

extern FILE *yyin;

int main(int argc, char **argv) {

	yyin = fopen(argv[1], "r");
	
	if (!yyin) {
		printf("cannot open"); 
		exit(1);
	}
	
	yyparse();
	
}
