%{
#include <stdio.h>
#include <stdlib.h>
#include <stdarg.h>
#include <string.h>
#include <assert.h>

typedef char *string;
//typedef char bool;

typedef union  {
	int pos;
	int ival;
	string sval;
	} YYSTYPE;

YYSTYPE yylval;

#define TRUE 1
#define FALSE 0

typedef struct U_boolList_ *U_boolList;
struct U_boolList_ {char head; U_boolList tail;};
U_boolList U_BoolList(char head, U_boolList tail);
char EM_anyErrors;

int EM_tokPos = 0;

# define ID 257
# define STRING 258
# define INT 259
# define COMMA 260
# define COLON 261
# define SEMICOLON 262
# define LPAREN 263
# define RPAREN 264
# define LBRACK 265
# define RBRACK 266
# define LBRACE 267
# define RBRACE 268
# define DOT 269
# define PLUS 270
# define MINUS 271
# define TIMES 272
# define DIVIDE 273
# define EQ 274
# define NEQ 275
# define LT 276
# define LE 277
# define GT 278
# define GE 279
# define AND 280
# define OR 281
# define ASSIGN 282
# define ARRAY 283
# define IF 284
# define THEN 285
# define ELSE 286
# define WHILE 287
# define FOR 288
# define TO 289
# define DO 290
# define LET 291
# define IN 292
# define END 293
# define OF 294
# define BREAK 295
# define NIL 296
# define FUNCTION 297
# define VAR 298
# define TYPE 299


extern "C" int yylex();

int charPos=1;

/*int yywrap(void)
{
 charPos=1;
 return 1;
}*/

void adjust(void)
{
 EM_tokPos=charPos;
 charPos+=yyleng;
}

/*
* Please don't modify the lines above.
* You can add C declarations of your own below.
*/

#define MAX_STR_LEN 1024

int commentLevel=0; /* for nested comment */

char string_buf[MAX_STR_LEN + 1];
char *string_buf_ptr;

void adjuststr(void)
{
 charPos+=yyleng;
}

void *checked_malloc(int len)
{void *p = malloc(len);
 if (!p) {
    fprintf(stderr,"\nRan out of memory!\n");
    exit(1);
 }
 return p;
}



bool anyErrors= FALSE;

static string fileName = NULL;

static int lineNum = 1;

extern FILE *yyin;

typedef struct intList {int i; struct intList *rest;} *IntList;

static IntList intList(int i, IntList rest) 
{IntList l= (IntList) checked_malloc(sizeof *l);
 l->i=i; l->rest=rest;
 return l;
}

static IntList linePos=NULL;

void EM_newline(void)
{lineNum++;
 linePos = intList(EM_tokPos, linePos);
}

void EM_error(int pos, char *message,...)
{va_list ap;
 IntList lines = linePos; 
 int num=lineNum;
 

  anyErrors=TRUE;
  while (lines && lines->i >= pos) 
       {lines=lines->rest; num--;}

  if (fileName) fprintf(stderr,"%s:",fileName);
  if (lines) fprintf(stderr,"%d.%d: ", num, pos-lines->i);
  va_start(ap,message);
  vfprintf(stderr, message, ap);
  va_end(ap);
  fprintf(stderr,"\n");

}

void EM_reset(string fname)
{
 anyErrors=FALSE; fileName=fname; lineNum=1;
 linePos=intList(0,NULL);
 yyin = fopen(fname,"r");
 string aux = (string) malloc(sizeof(string));
 strcpy(aux, "canot open");
 if (!yyin) {EM_error(0, aux); exit(1);}
}




string String(char *s)
{string p = (string) checked_malloc(strlen(s)+1);
 strcpy(p,s);
 return p;
}

U_boolList U_BoolList(bool head, U_boolList tail)
{ U_boolList list = (U_boolList) checked_malloc(sizeof(U_boolList));
  list->head = head;
  list->tail = tail;
  return list;
}



%}
  /* You can add lex definitions here. */

%x str comment
%%
  /* 
  * Below are some examples, which you can wipe out
  * and write reguler expressions and actions of your own.
  */ 

  /* string */
<str>
{

\"  {
    adjuststr();
    *string_buf_ptr='\0';
    if (string_buf[0] != '\0') {
      yylval.sval=String(string_buf);
    }
    else {
      string s = (string) malloc(sizeof(string));
      strcpy(s, "(null)");
      yylval.sval=String(s); /* Compatible with test case */
      }
    BEGIN(INITIAL);
    return STRING;
  }

\\[0-9]{3} {
    adjuststr();
    int result = atoi(yytext + 1);
    if (result > 0xff) {
      string s = (string) malloc(sizeof(string));
      strcpy(s, "illegal character");
      EM_error(EM_tokPos, s);
      continue;
    }
    *string_buf_ptr++ = result;
  }

\\n     {adjuststr(); *string_buf_ptr++ = '\n';}
\\t     {adjuststr(); *string_buf_ptr++ = '\t';}
\\\"    {adjuststr(); *string_buf_ptr++ = '\"';}
\\\\    {adjuststr(); *string_buf_ptr++ = '\\';}
\\\^[\0-\037]   {
    adjuststr();
    *string_buf_ptr++ = yytext[2];
  }

\\[ \t\n\r]+\\ {
    adjuststr();
    char *yytextptr = yytext;
    while (*yytextptr != '\0')
    {
      if (*yytextptr == '\n')
        EM_newline();
      ++yytextptr;
    }
  }

\\. {adjuststr();
     string s = (string) malloc(sizeof(string));
     strcpy(s, "illegal escape char"); 
     EM_error(charPos, s);}

\n  {
    adjuststr();
    EM_newline();
    string s = (string) malloc(sizeof(string));
    strcpy(s, "string terminated with newline");
    EM_error(charPos, s);
    continue;
  }

[^\\\n\"]+        {
    adjuststr();
    char *yptr = yytext;

    while (*yptr)
      *string_buf_ptr++ = *yptr++;
  }
}

  /* comment */
<*>"/*" {adjust(); ++commentLevel; BEGIN(comment);}

<comment>{
  \n    {adjust(); EM_newline();}
  "*/"  {adjust(); --commentLevel; if (commentLevel <= 0) BEGIN(INITIAL);}
  .     {adjust();}
}

<INITIAL>{

  (" "|"\t")  {adjust();} 
  \n	  {adjust(); EM_newline();}

  ","	  {adjust(); return COMMA;}
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

  array {adjust(); return ARRAY;}
  if    {adjust(); return IF;}
  then  {adjust(); return THEN;}
  else  {adjust(); return ELSE;}
  while {adjust(); return WHILE;}
  for   {adjust(); return FOR;}
  to    {adjust(); return TO;}
  do    {adjust(); return DO;}
  let   {adjust(); return LET;}
  in    {adjust(); return IN;}
  end   {adjust(); return END;}
  of    {adjust(); return OF;}
  break {adjust(); return BREAK;}
  nil   {adjust(); return NIL;}
  function  {adjust(); return FUNCTION;}
  var   {adjust(); return VAR;}
  type  {adjust(); return TYPE;}

  [0-9]+	 {adjust(); yylval.ival=atoi(yytext); return INT;}
  [a-zA-Z][a-zA-Z0-9_]* {adjust(); yylval.sval=String(yytext); return ID;}

  \"   {
    adjust();
    string_buf_ptr = string_buf;
    BEGIN(str);
  }
}

.	 {adjust(); 
          string s = (string) malloc(sizeof(string));
          strcpy(s, "illegal token");
          EM_error(EM_tokPos, s);}

%%

int yylex(void); /* prototype for the lexing function */

string toknames[43];

int i = 0;



string tokname(int tok) {
  string s;

  if (tok<257 || tok>299) {
    s = (string) malloc(sizeof(string));
    strcpy(s, "BAD_TOKEN");
  }
  else {
    s = toknames[tok-257];
  }
  return s;
}

int main(int argc, char **argv) {
 string fname; int tok;
 //if (argc!=2) {fprintf(stderr,"usage: a.out filename\n"); exit(1);}
 fname=argv[1];
 EM_reset(fname);
 
 for(i = 0; i<43; i++) {
  switch (i) {
  	case 0:
  	  toknames[i] = (string) malloc(sizeof(string));
  	  strcpy(toknames[i], "ID");
  	break;
  	
  	case 1:
  	  toknames[i] = (string) malloc(sizeof(string));
  	  strcpy(toknames[i], "STRING");
  	break;
  	
  	case 2:
  	  toknames[i] = (string) malloc(sizeof(string));
  	  strcpy(toknames[i], "INT");
  	break;
  	
  	case 3:
  	  toknames[i] = (string) malloc(sizeof(string));
  	  strcpy(toknames[i], "COMMA");
  	break;
  	
  	case 4:
  	  toknames[i] = (string) malloc(sizeof(string));
  	  strcpy(toknames[i], "COLON");
  	break;
  	
  	case 5:
  	  toknames[i] = (string) malloc(sizeof(string));
  	  strcpy(toknames[i], "SEMICOLON");
  	break;
  	
  	case 6:
  	  toknames[i] = (string) malloc(sizeof(string));
  	  strcpy(toknames[i], "LPAREN");
  	break;
  	
  	case 7:
  	  toknames[i] = (string) malloc(sizeof(string));
  	  strcpy(toknames[i], "RPAREN");
  	break;
  	
  	case 8:
  	  toknames[i] = (string) malloc(sizeof(string));
  	  strcpy(toknames[i], "LBRACK");
  	break;
  	
  	case 9:
  	  toknames[i] = (string) malloc(sizeof(string));
  	  strcpy(toknames[i], "RBRACK");
  	break;
  	
  	case 10:
  	  toknames[i] = (string) malloc(sizeof(string));
  	  strcpy(toknames[i], "LBRACE");
  	break;
  	
  	case 11:
  	  toknames[i] = (string) malloc(sizeof(string));
  	  strcpy(toknames[i], "RBRACE");
  	break;
  	
  	case 12:
  	  toknames[i] = (string) malloc(sizeof(string));
  	  strcpy(toknames[i], "DOT");
  	break;
  	
  	case 13:
  	  toknames[i] = (string) malloc(sizeof(string));
  	  strcpy(toknames[i], "PLUS");
  	break;
  	
  	case 14:
  	  toknames[i] = (string) malloc(sizeof(string));
  	  strcpy(toknames[i], "MINUS");
  	break;
  	
  	case 15:
  	  toknames[i] = (string) malloc(sizeof(string));
  	  strcpy(toknames[i], "TIMES");
  	break;
  	
  	case 16:
  	  toknames[i] = (string) malloc(sizeof(string));
  	  strcpy(toknames[i], "DIVIDE");
  	break;
  	
  	case 17:
  	  toknames[i] = (string) malloc(sizeof(string));
  	  strcpy(toknames[i], "EQ");
  	break;
  	
  	case 18:
  	  toknames[i] = (string) malloc(sizeof(string));
  	  strcpy(toknames[i], "NEQ");
  	break;
  	
  	case 19:
  	  toknames[i] = (string) malloc(sizeof(string));
  	  strcpy(toknames[i], "LT");
  	break;
  	
  	case 20:
  	  toknames[i] = (string) malloc(sizeof(string));
  	  strcpy(toknames[i], "LE");
  	break;
  	
  	case 21:
  	  toknames[i] = (string) malloc(sizeof(string));
  	  strcpy(toknames[i], "GT");
  	break;
  	
  	case 22:
  	  toknames[i] = (string) malloc(sizeof(string));
  	  strcpy(toknames[i], "GE");
  	break;
  	
  	case 23:
  	  toknames[i] = (string) malloc(sizeof(string));
  	  strcpy(toknames[i], "AND");
  	break;
  	
  	case 24:
  	  toknames[i] = (string) malloc(sizeof(string));
  	  strcpy(toknames[i], "OR");
  	break;
  	
  	case 25:
  	  toknames[i] = (string) malloc(sizeof(string));
  	  strcpy(toknames[i], "ASSIGN");
  	break;
  	
  	case 26:
  	  toknames[i] = (string) malloc(sizeof(string));
  	  strcpy(toknames[i], "ARRAY");
  	break;
  	
  	case 27:
  	  toknames[i] = (string) malloc(sizeof(string));
  	  strcpy(toknames[i], "IF");
  	break;
  	
  	case 28:
  	  toknames[i] = (string) malloc(sizeof(string));
  	  strcpy(toknames[i], "THEN");
  	break;
  	
  	case 29:
  	  toknames[i] = (string) malloc(sizeof(string));
  	  strcpy(toknames[i], "ELSE");
  	break;
  	
  	case 30:
  	  toknames[i] = (string) malloc(sizeof(string));
  	  strcpy(toknames[i], "WHILE");
  	break;
  	
  	case 31:
  	  toknames[i] = (string) malloc(sizeof(string));
  	  strcpy(toknames[i], "FOR");
  	break;
  	
  	case 32:
  	  toknames[i] = (string) malloc(sizeof(string));
  	  strcpy(toknames[i], "TO");
  	break;
  	
  	case 33:
  	  toknames[i] = (string) malloc(sizeof(string));
  	  strcpy(toknames[i], "DO");
  	break;
  	
  	case 34:
  	  toknames[i] = (string) malloc(sizeof(string));
  	  strcpy(toknames[i], "LET");
  	break;
  	
  	case 35:
  	  toknames[i] = (string) malloc(sizeof(string));
  	  strcpy(toknames[i], "IN");
  	break;
  	
  	case 36:
  	  toknames[i] = (string) malloc(sizeof(string));
  	  strcpy(toknames[i], "END");
  	break;
  	
  	case 37:
  	  toknames[i] = (string) malloc(sizeof(string));
  	  strcpy(toknames[i], "OF");
  	break;
  	
  	case 38:
  	  toknames[i] = (string) malloc(sizeof(string));
  	  strcpy(toknames[i], "BREAK");
  	break;
  	
  	case 39:
  	  toknames[i] = (string) malloc(sizeof(string));
  	  strcpy(toknames[i], "NIL");
  	break;
  	
  	case 40:
  	  toknames[i] = (string) malloc(sizeof(string));
  	  strcpy(toknames[i], "FUNCTION");
  	break;
  	
  	case 41:
  	  toknames[i] = (string) malloc(sizeof(string));
  	  strcpy(toknames[i], "VAR");
  	break;
  	
  	case 42:
  	  toknames[i] = (string) malloc(sizeof(string));
  	  strcpy(toknames[i], "TYPE");
  	break;
  	
  	default :
  	;
  	  //faz nada
  }
}
 for(;;) {
   tok=yylex();
   if (tok==0) break;
   switch(tok) {
   case ID: case STRING:
     printf("%10s %4d %s\n",tokname(tok),EM_tokPos,yylval.sval);
     break;
   case INT:
     printf("%10s %4d %d\n",tokname(tok),EM_tokPos,yylval.ival);
     break;
   default:
     printf("%10s %4d\n",tokname(tok),EM_tokPos);
   }
 }
 return 0;
 }
