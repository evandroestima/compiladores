#include <stdio.h>
#include <stdlib.h>
#include "tiger.tab.h"
#include "ast.h"

extern FILE *yyin;

int main(int argc, char **argv) {

	yyin = fopen(argv[1], "r");
	
	if (!yyin) {
		printf("cannot open"); 
		exit(1);
	}
	
	yyparse();
	arv.ini->print(arv.ini, 0);
}
