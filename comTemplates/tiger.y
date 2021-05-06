%{
#include <stdio.h>
#include <stdlib.h>
#include <stdarg.h>
#include <string.h>
#include "ast.h"
#include "errormsg.h"
#include "util.h"
#include "symbol.h"

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
                | LPAREN explist RPAREN	{$$ = $1;}
                | cond			    	{$$ = $1;}
                | let				{$$ = $1;}
                | exp OR exp			{$$ = A_OpExp(0, A_orOp, $1, $3);}
                | exp AND exp			{$$ = A_OpExp(0, A_andOp, $1, $3);}
                | exp LT exp			{$$ = A_OpExp(0, A_ltOp, $1, $3);}
                | exp GT exp			{$$ = A_OpExp(0, A_gtOp, $1, $3);}
                | exp LE exp			{$$ = A_OpExp(0, A_leOp, $1, $3);}
                | exp GE exp			{$$ = A_OpExp(0, A_geOp, $1, $3);}
                | exp PLUS exp		{$$ = A_OpExp(0, A_plusOp, $1, $3);}
                | exp MINUS exp		{$$ = A_OpExp(0, A_minusOp, $1, $3);}
                | exp TIMES exp		{$$ = A_OpExp(0, A_timesOp, $1, $3);}
                | exp DIVIDE exp		{$$ = A_OpExp(0, A_divideOp, $1, $3);}
                | MINUS exp %prec UMINUS	{$$ = A_OpExp(0, A_minusOp, 0, $2);}
                | exp EQ exp			{$$ = A_OpExp(0, A_eqOp, $1, $3);}
                | exp NEQ exp			{$$ = A_OpExp(0, A_neqOp, $1, $3);}
                | id LPAREN arglist RPAREN	{$$ = A_CallExp(0, $1, $3);}
                | id LPAREN RPAREN		{$$ = A_CallExp(0, $1, NULL);}
                | id LBRACK exp RBRACK OF exp	{$$ = A_ArrayExp(0, S_Symbol($1), $3, $6);}			//PENDENTE;
                | id LBRACE reclist RBRACE	{$$ = A_RecordExp(0, S_Symbol($1), $3);}
                | id LBRACE RBRACE		{$$ = A_RecordExp(0, S_Symbol($1), NULL);}			//
                | BREAK			{$$ = A_BreakExp(0);}
                ;

reclist:        /* empty */                   {$$ = NULL;}
                | id EQ exp			{$$ = A_EfieldList(A_Efield(S_Symbol($1), $3), NULL);}
                | id EQ exp	COMMA reclist	{$$ = A_EfieldList(A_Efield(S_Symbol($1), $3), $5);}
                

let:              LET decs IN explist END	{$$ = A_LetExp(0, $2, $4);}
                ;

arglist:        exp				{$$ = A_ExpList($1, NULL);}
                | exp COMMA arglist		{$$ = A_ExpList($1, $3);}
                ;

decs:           dec				{$$ = A_DecList($1, NULL);}
		 | dec decs			{$$ = A_DecList($1, $2);}
                ;

dec:              tydec 			{$$ = A_TypeDec(0, A_NametyList($1, NULL));}
                | vardec			{$$ = A_VarDec(0, NULL, NULL, A_ExpList($1, NULL));}
                | fundec			{$$ = A_FunctionDec(0, A_FundecList($1, NULL));}
                ;

lvalue:           id %prec LOW                      {$$ = A_SimpleVar(0, S_Symbol($1));}
                | id LBRACK exp RBRACK 		{$$ = A_SubscriptVar(0, $1, $3);}
                | lvalue LBRACK exp RBRACK		{$$ = A_SubscriptVar(0, $1, $3);}
                | lvalue DOT id			{$$ = A_FieldVar(0, $1, S_Symbol($3));}
                ;

explist:		/* empty */			{$$ = NULL;}
                | exp					{$$ = A_ExpList($1, NULL);}
                | exp SEMICOLON explist		{$$ = A_ExpList($1, $3);}
                ;

cond:             IF exp THEN exp ELSE exp			{$$ = A_IfExp(0, $2, $4, $6);}
                | IF exp THEN exp				{$$ = A_IfExp(0, $2, $4, NULL);}
                | WHILE exp DO exp				{$$ = A_WhileExp(0, $2, $4);}
                | FOR id ASSIGN exp TO exp DO exp		{$$ = A_ForExp(0, $2, $4, $6, $8);}
                ;

tydec:            TYPE id EQ ty				{$$ = A_TypeDec(0, A_NametyList($2, $4));}
                ;

ty:               id						{$$ = A_NameTy(0, S_Symbol($1));}
                | LBRACE tyfields RBRACE			{$$ = A_EfieldList(NULL, $2);}
                | ARRAY OF id					{$$ = A_ArrayTy(0, S_Symbol($3));}
                ;

tyfields:       /* empty */					{$$ = NULL;}
                | tyfield					{$$ = A_EfieldList($1, NULL);}
                | tyfield COMMA tyfields			{$$ = A_EfieldList($1, $3);}
                ;

tyfield:          id COLON id					{$$ = A_Efield(S_Symbol($1), $3);}
                ;

vardec:           VAR id ASSIGN exp				{$$ = A_VarExp(0, A_SubscriptVar(0, $2, $4));}
                | VAR id COLON id ASSIGN exp			{$$ = A_VarExp(0, A_VarDec(0, $2, $4, $6));}
                ;

id:               ID						{$$ = $1;}
                ;

fundec:           FUNCTION id LPAREN tyfields RPAREN EQ exp	{A_Fundec(0, S_Symbol($2), A_EfieldList(NULL, $4), NULL, $7);}
                | FUNCTION id LPAREN tyfields RPAREN COLON id EQ exp	{A_Fundec(0, S_Symbol($2), A_EfieldList(NULL, $4), S_Symbol(), $9);}
                ;
                
                
                
%%


