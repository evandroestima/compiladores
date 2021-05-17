#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <string.h>
#include "util.h"
#include "errormsg.h"
#include "tiger.tab.h"
#include "ast.h"
#include "prabsyn.h"
#include "semantic.h"

YYSTYPE yylval;

int yylex(void); /* prototype for the lexing function */

extern int yyparse(void);

void parse(char *fname) 
{EM_reset(fname);
 if (yyparse() == 0) /* parsing worked */
   fprintf(stderr,"Parsing successful!\n\n");
 else fprintf(stderr,"Parsing failed\n");
}


char* toknames[] = {
"ID", "STRING", "INT", "COMMA", "COLON", "SEMICOLON", "LPAREN",
"RPAREN", "LBRACK", "RBRACK", "LBRACE", "RBRACE", "DOT", "PLUS",
"MINUS", "TIMES", "DIVIDE", "EQ", "NEQ", "LT", "LE", "GT", "GE",
"AND", "OR", "ASSIGN", "ARRAY", "IF", "THEN", "ELSE", "WHILE", "FOR",
"TO", "DO", "LET", "IN", "END", "OF", "BREAK", "NIL", "FUNCTION",
"VAR", "TYPE"
};


char* tokname(int tok) {
  return tok<257 || tok>299 ? "BAD_TOKEN" : toknames[tok-257];
}

int main(int argc, char **argv) {

 char *fname; int tok;
 bool printar_arvore = false;
 
 int opt;
 while((opt=getopt(argc, argv,"ap:")) != -1) {
 	switch (opt) {
 		case 'p': {
 			fname = strdup(optarg);
 		}
 		break;
 		
 		case 'a': {
 			printar_arvore = true;
 		}
 		break;
 	}
 }
 
 parse(fname);
 if (printar_arvore) {
 	pr_exp(stdout, arv.ini, 0);
 	printf("\n\n");
 }
 venv = S_empty();
 tenv = S_empty();
 
 S_beginScope(tenv);
 S_enter(tenv, S_Symbol("int"), Ty_Int());
 S_enter(tenv, S_Symbol("string"), Ty_String());
 
 transExp(arv.ini);
 
 return 0;
}



