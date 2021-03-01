%{
#include <string.h>
#include <limits.h>
#include "util.h"
#include "tokens.h"
#include "errormsg.h"

#define MAX_STR_CONST 16384

int charPos=1;
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

extern YYSTYPE yylloc; 

%}

%s comment
%s in_string 

%%


\" {BEGIN(in_string);
    string_buf_ptr = string_buf;

    adjust();
}

<in_string> 
{
\" {
   char * p;
   BEGIN(INITIAL);
   *string_buf_ptr = '\0';

   p = malloc ((strlen(string_buf) +1) *sizeof(char));
   strcpy(p, string_buf);
   yylval.sval = p;
   adjust();
   return STRING;
   }
       
\n {
    	adjust();
        perror ("constante string não encerrada");
       }

<<EOF>> {
             adjust();
             perror ("constante string não encerrada");
    }

\\n {*string_buf_ptr++ = '\n';}
\\t {*string_buf_ptr++ = '\t';}
\\\" {*string_buf_ptr++ = '"';}
\\\\ {*string_buf_ptr++ = '\\';}
    
\\^[a-z] {
    		if (strchr ("abcdefghijklmnopqrstuvwxyz", yytext[2])){
        		*string_buf_ptr = (yytext[2] - 'a' +1);
    		}
    		else {
        		perror("sequência de escape ilegal");
    		}
	     }

\\[0-9]{3} {
    		int i = atoi(&yytext[1]);
    		if (i > 255)
    		    perror("sequência de escape ilegal");
    
    		*string_buf_ptr++ = (char)i;
		 }

\\[\n\t]+\\ {
        /* faz nada */
    }

\\. {
        adjust();
        perror("sequência de escape ilegal");
    }


[^\\\n\"]+ {
        char * p = yytext; 

        while (*p)
            *string_buf_ptr++ = *p++;
    }
}


"/*" {adjust(); ++commentLevel; BEGIN(comment);}

<comment>{
  \n    {adjust();}
  "*/"  {adjust(); --commentLevel; if (commentLevel <= 0) BEGIN(INITIAL);}
  <<EOF>> {adjust(); perror("comentário não encerrado"); }
  .     {adjust();}
}

[ \t]+ {adjust();}
"array" {adjust(); return ARRAY;}
"if" {adjust(); return IF;}
"then" {adjust(); return THEN;}
"else" {adjust(); return ELSE;}
"while" {adjust(); return WHILE;}
"for" {adjust(); return FOR;}
"to" {adjust(); return TO;}
"do" {adjust(); return DO;}
"let" {adjust(); return LET;}
"in" {adjust(); return IN;}
"end" {adjust(); return END;}
"of" {adjust(); return OF;}
"break" {adjust(); return BREAK;}
"nil" {adjust(); return NIL;}
"function" {adjust(); return FUNCTION;}
"var" {adjust(); return VAR;}
"type" {adjust(); return TYPE;}



" "	 {adjust(); continue;}
"for"   {adjust(); return FOR;}

[0-9]+ {
    char * buf = (char *) malloc(20);
    long int value; 
    
    adjust();

    value = strtol (yytext, &buf, 10);

    if (value = LONG_MAX || value > INT_MAX){
        perror("inteiro inválido");
        exit(1);
    }
    yylval.ival = value;
    return INTLIT;
}

[a-zA-Z][0-9a-zA-Z]* {
    char * buf = (char *) malloc ((yyleng + 1) * sizeof(char));
    strcpy(buf, yytext);
    yylval.sval = buf;

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
 
%%
