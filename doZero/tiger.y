%{
#include <stdio.h>
#include <stdlib.h>
#include <stdarg.h>

int yylex(void); /* function prototype */
void yyerror(char *s, ...);

%}

%locations
%union {
  int ival;
  char *sval;
  
}

%token ID STRING
%token INT

%token
  COMMA COLON SEMICOLON LPAREN RPAREN LBRACK RBRACK LBRACE RBRACE DOT
  PLUS MINUS TIMES DIVIDE EQ NEQ LT LE GT GE AND OR ASSIGN
  ARRAY IF THEN ELSE WHILE FOR TO DO LET IN END OF BREAK NIL FUNCTION VAR TYPE

%nonassoc LOW
%nonassoc THEN DO TYPE FUNCTION ID
%nonassoc ASSIGN LBRACK ELSE OF COMMA
%left OR
%left AND
%nonassoc EQ NEQ LE LT GT GE
%left PLUS MINUS
%left TIMES DIVIDE
%left UMINUS

%start prog

%%

prog:             root                              {}
                ;

root:           /* empty */                         {}
                | exp								{}

exp:              INT                       		{}
                | STRING							{}
                | NIL								{}
                | lvalue							{}
                | lvalue ASSIGN exp					{}
                | LPAREN explist RPAREN				{}
                | cond						    	{}
                | let						    	{}
                | exp OR exp						{}
                | exp AND exp						{}
                | exp LT exp						{}
                | exp GT exp						{}
                | exp LE exp						{}
                | exp GE exp						{}
                | exp PLUS exp						{}
                | exp MINUS exp						{}
                | exp TIMES exp						{}
                | exp DIVIDE exp					{}
                | MINUS exp %prec UMINUS			{}
                | exp EQ exp						{}
                | exp NEQ exp						{}
                | id LPAREN arglist RPAREN			{}
                | id LBRACK exp RBRACK OF exp		{}
                | id LBRACE reclist RBRACE			{}
                | BREAK								{}
                ;

reclist:        /* empty */                         {}
                | id EQ exp							{}
                | id EQ exp	COMMA reclist		{}

let:              LET decs IN explist END			{}
                ;

arglist:        /* empty */							{}
                | nonarglist						{}
                ;

nonarglist:       exp								{}
                | exp COMMA nonarglist				{}
                ;

decs:           dec							{}
		 | dec decs							{}
                ;

dec:              tydec 							{}
                | vardec							{}
                | fundec							{}
                ;

lvalue:           id %prec LOW                      {}
                | id LBRACK exp RBRACK 				{}
                | lvalue LBRACK exp RBRACK			{}
                | lvalue DOT id						{}
                ;

explist:		/* empty */							{}
                | exp								{}
                | exp SEMICOLON explist				{}
                ;

cond:             IF exp THEN exp ELSE exp			{}
                | IF exp THEN exp					{}
                | WHILE exp DO exp					{}
                | FOR id ASSIGN exp TO exp DO exp	{}
                ;

tydec:            TYPE id EQ ty						{}
                ;

ty:               id								{}
                | LBRACE tyfields RBRACE			{}
                | ARRAY OF id						{}
                ;

tyfields:       /* empty */							{}
                | tyfield							{}
                | tyfield COMMA tyfields			{}
                ;

tyfield:          id COLON id						{}
                ;

vardec:           VAR id ASSIGN exp					{}
                | VAR id COLON id ASSIGN exp		{}
                ;

id:               ID								{}
                ;

fundec:           FUNCTION id LPAREN tyfields RPAREN EQ exp				{}
                | FUNCTION id LPAREN tyfields RPAREN COLON id EQ exp	{}
                ;
                
                
                
%%

void yyerror(char *s, ...)
{
    va_list ap;
    va_start(ap, s);

    //fprintf(stderr, "[ERRO NA LINHA %d]: ", yylineno);
    vfprintf(stderr, s, ap);
    fprintf(stderr, "\n");
    abort();
}


