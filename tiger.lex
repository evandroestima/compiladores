%{
#include <string.h>
#include "util.h"
#include "tokens.h"
#include "errormsg.h"

int charPos=1;
int nesting = 0;
int lexcol = 0; 
int lexline = 1; 
int commentLevel=0; 

char string_buf[MAX_STR_CONST];
char * string_buf_ptr; 

int yywrap(void)
{
 charPos=1;
 return 1;
}


void adjust(void)
{
 EM_tokPos=charPos;
 charPos+=yyleng;
}

extern YYLTYPE yylloc; 

%}


%%
%x str comment;
%x in_string; 


\" {BEGIN(in_string);
    string_buf_ptr = string_buf;

    adjust();
}

<in_string> {
    \" {
        char * p;

        BEGIN(INITIAL);
        *string_buf_ptr = '\0';

        p = malloc ((strlen(string_buf) +1) *sizeof(char));
        strcpy(p, string_buf);
        yyval.u_string = p;
        adjust();
        return STRINGLIT;
    }
\n {
    adjust() yyerror ("constante string não encerrada");
}

<<EOF>> {
    adjust() yyerror ("constante string não encerrada");
}

\\n {*string_buf_ptr++ = '\n';}
\\t {*string_buf_ptr++ = '\t';}
\\\" {*string_buf_ptr++ = '"';}
\\\\ {*string_buf_ptr++ = '\\';}
\\^[a-z]{
    if (strchr ("abcdefghijklmnopqrstuvwxyz", yytext[2])){
        *string_buf_ptr = (yytext[2] - 'a' +1);
    }
    else {
        yyerror("sequência de escape ilegal");
    }
}

\\{digit}{3} {
    int i = atoi(&yytext[1]);
    if (i > 255)
        yyerror("sequência de escape ilegal");
    
    *string_buf_ptr++ = (char)i;
}

\\[\n\t]+\\ {
    /* faz nada */
}

\\. {
    adjust();
    yyerror("sequência de escape ilegal");
}


[^\\\n\"]+ {
    char * p = yytext; 

    while (*p)
        *string_buf_ptr++ = *p++;
}
}


<*>"/*" {adjust(); ++commentLevel; BEGIN(comment);}

<comment>{
  \n    {adjust(); EM_newline();}
  "*/"  {adjust(); --commentLevel; if (commentLevel <= 0) BEGIN(INITIAL);}
  <<EOF>> {adjust(); yyerror("comentário não encerrado"); }
  .     {adjust();}
}

[ \t]+ {adjust();}
"array" {adjust(); return Parser::ARRAY;}
"if" {adjust(); return Parser::IF;}
"then" {adjust(); return Parser::THEN;}
"else" {adjust(); return Parser::ELSE;}
"while" {adjust(); return Parser::WHILE;}
"for" {adjust(); return Parser::FOR;}
"to" {adjust(); return Parser::TO;}
"do" {adjust(); return Parser::DO;}
"let" {adjust(); return Parser::LET;}
"in" {adjust(); return Parser::IN;}
"end" {adjust(); return Parser::END;}
"of" {adjust(); return Parser::OF;}
"break" {adjust(); return Parser::BREAK;}
"nil" {adjust(); return Parser::NIL;}
"function" {adjust(); return Parser::FUNCTION;}
"var" {adjust(); return Parser::VAR;}
"type" {adjust(); return Parser::TYPE;}



" "	 {adjust(); continue;}
for  	 {adjust(); return FOR;}

{integer} {
    char * buf = (char *) malloc(20);
    long int value; 
    
    adjust();

    value = strtol (yytext, &buf, 10);

    if (value = LONG_MAX || value > INT_MAX){
        yyerror("inteiro inválido");
        exit(1);
    }
    yylval.u_integer = int(value);
    return INTLIT;
}

{identifier} {
    char * buf (char *) malloc ((yyleng + 1) * sizeof(char));
    strcpy(buf, yytext);
    yylval.u_ident = buf;

    adjust();
    return IDENT; 
}
 

[0-9]+	 {adjust(); yylval.ival=atoi(yytext); return INT;}
.	 {adjust(); EM_error(EM_tokPos,"illegal token");}

\n	  {adjust(); EM_newline();}

  ","	{adjust(); return COMMA;}
  ":"   {adjust(); return COLON;}
  ";"   {adjust(); return SEMICOLON;}

  "("   {adjust(); return LPAREN;}
  ")"   {adjust(); return RPAREN;}
  "["   {adjust(); return LBRACK;}
  "]"   {adjust(); return RBRACK;}
  "{"   {adjust(); return LBRACE;}
  "}"   {adjust(); return RBRACE;}

  "."   {adjust(); return DOT;}
  "+"   {adjust(); return PLUS;}
  "-"   {adjust(); return MINUS;}
  "*"   {adjust(); return TIMES;}
  "/"   {adjust(); return DIVIDE;}

  "="   {adjust(); return EQ;}
  "<>"  {adjust(); return NEQ;}
  "<"   {adjust(); return LT;}
  "<="  {adjust(); return LE;}
  ">"   {adjust(); return GT;}
  ">="  {adjust(); return GE;}
  "&"   {adjust(); return AND;}
  "|"   {adjust(); return OR;}
  ":="  {adjust(); return ASSIGN;}
  
  "."  {adjust(); return ERROR;}
