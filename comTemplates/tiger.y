%{
#include <stdio.h>
#include <stdlib.h>
#include <stdarg.h>
#include "ast.h"
#include "errormsg.h"
#include "util.h"

int yylex(void); /* function prototype */
void yyerror(char *s)
{
 EM_error(EM_tokPos, "%s", s);
}

%}

%locations
%union {
  int ival;
  char *sval;
  struct no *no;
}

%token <sval> ID STRING
%token <ival> INT

%token
  COMMA COLON SEMICOLON LPAREN RPAREN LBRACK RBRACK LBRACE RBRACE DOT
  PLUS MINUS TIMES DIVIDE EQ NEQ LT LE GT GE AND OR ASSIGN
  ARRAY IF THEN ELSE WHILE FOR TO DO LET IN END OF BREAK NIL FUNCTION VAR TYPE

%type <no> exp

%nonassoc LOW
%nonassoc THEN DO TYPE FUNCTION ID
%nonassoc ASSIGN LBRACK ELSE OF COMMA
%left OR
%left AND
%nonassoc EQ NEQ LE LT GT GE
%left PLUS MINUS
%left TIMES DIVIDE
%left UMINUS

%%

root:           /* empty */                   {printf("\n Programa vazio");}
                | exp				{arv.ini = $1;}

exp:              INT                       	{$$ = A_IntExp(0, atoi($1));}
                | STRING			{$$ = A_StringExp(0, $1);}
                | NIL				{$$ = A_NilExp(0);}
                | lvalue			{$$ = A_VarExp(0, $1);}
                | lvalue ASSIGN exp		{$$ = A_AssignExp(0, $1, $3);}
                | LPAREN explist RPAREN	{$$ = A_StringExp(0, $2);}
                | cond			    	{$$ = A_StringExp(0, $1);}
                | let				{$$ = A_StringExp(0, $1);}
                | exp OR exp			{}
                | exp AND exp			{}
                | exp LT exp			{$$ = A_OpExp(0, A_ltOp, $1, $3);}
                | exp GT exp			{$$ = A_OpExp(0, A_gtOp, $1, $3);}
                | exp LE exp			{$$ = A_OpExp(0, A_leOp, $1, $3);}
                | exp GE exp			{$$ = A_OpExp(0, A_geOp, $1, $3);}
                | exp PLUS exp		{$$ = A_OpExp(0, A_plusOp, $1, $3);}
                | exp MINUS exp		{$$ = A_OpExp(0, A_minusOp, $1, $3);}
                | exp TIMES exp		{$$ = A_OpExp(0, A_timesOp, $1, $3);}
                | exp DIVIDE exp		{$$ = A_OpExp(0, A_divideOp, $1, $3);}
                | MINUS exp %prec UMINUS			{}
                | exp EQ exp			{$$ = A_OpExp(0, A_eqOp, $1, $3);}
                | exp NEQ exp			{$$ = A_OpExp(0, A_neqOp, $1, $3);}
                | id LPAREN arglist RPAREN	{$$ = A_CallExp(0, $1, $3);}
                | id LBRACK exp RBRACK OF exp		{}
                | id LBRACE reclist RBRACE	{}
                | BREAK			{$$ = A_BreakExp(0);}
                ;

reclist:        /* empty */                         {}
                | id EQ exp							{}
                | id EQ exp	COMMA reclist		{}

let:              LET decs IN explist END	{$$ = A_LetExp(0, $2, $4);}
                ;

arglist:        /* empty */							{}
                | nonarglist						{}
                ;

nonarglist:       exp				{$$ = A_StringExp(0, $1);}
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

explist:		/* empty */			{$$ = NULL;}
                | exp					{$$ = A_StringExp(0, $1);}
                | exp SEMICOLON explist		{$$ = A_ExpList($1, $3);}
                ;

cond:             IF exp THEN exp ELSE exp			{$$ = A_IfExp(0, $2, $4, $6);}
                | IF exp THEN exp				{$$ = A_IfExp(0, $2, $4, NULL);}
                | WHILE exp DO exp				{$$ = A_WhileExp(0, $2, $4);}
                | FOR id ASSIGN exp TO exp DO exp		{$$ = A_ForExp(0, $2, $4, $6, $8);}
                ;

tydec:            TYPE id EQ ty						{}
                ;

ty:               id								{}
                | LBRACE tyfields RBRACE			{}
                | ARRAY OF id						{}
                ;

tyfields:       /* empty */					{$$ = NULL;}
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


