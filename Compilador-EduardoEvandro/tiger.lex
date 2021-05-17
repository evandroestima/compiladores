%option noyywrap
%x COMMENT STRING
%{
#include <stdio.h>
#include <string.h>
#include "tiger.tab.h"
#include "ast.h"

#define BUFFSIZE 255

int buffer_len;
char buffer[BUFFSIZE + 1];

int comment_level = 0;

int yycolumn = 0, yyline = 1;

%}

digit [0-9]
alpha [a-zA-Z]
number {digit}+
identifier {alpha}("_"|{alpha}|{digit})*

%%

"type" { return TYPE; }
"array" { return ARRAY; }
"of" { return OF; }
"var" { return VAR; }
"function" { return FUNCTION; }
"nil" { return NIL; }
"if" { return IF; }
"then" { return THEN; }
"else" { return ELSE; }
"while" { return WHILE; }
"for" { return FOR; }
"to" { return TO; }
"do" { return DO; }
"break" { return BREAK; }
"let" { return LET; }
"in" { return IN; }
"end" { return END; }

"," { return COMMA; }
":" { return COLON; }
";" { return SEMICOLON; }
"(" { return LPAREN; }
")" { return RPAREN; }
"[" { return LBRACK; }
"]" { return RBRACK; }
"{" { return LBRACE; }
"}" { return RBRACE; }
"." { return DOT; }
"+" { return PLUS; }
"-" { return MINUS; }
"*" { return TIMES; }
"/" { return DIVIDE; }
"=" { return EQ; }
"<>" { return NEQ; }
"<" { return LT; }
">" { return GT; }
"<=" { return LE; }
">=" { return GE; }
":=" { return ASSIGN; }
"&" { return AND; }
"|" { return OR; }
[ \t] { }
"\n" { yycolumn = 1; ++yyline; }

{identifier} {
    yylval.sval = strdup(yytext);
    return ID;
}

{number} { yylval.ival = atoi(yytext); return INT; }

"\"" {
    BEGIN STRING;
    yylval.sval = NULL;
    buffer[0] = '\0';
    buffer_len = 0;
}

. {
    fprintf(stderr, "[ERRO LEXICO - %d:%d] token invalido.\n",
            yylloc.first_line, yylloc.first_column);
    exit(1);  }

<STRING>"\\a" {
    buffer[buffer_len++] = '\a';
}
<STRING>"\\b" {
    buffer[buffer_len++] = '\b';
}
<STRING>"\\f" {
    buffer[buffer_len++] = '\f';
}
<STRING>"\\n" {
    buffer[buffer_len++] = '\n';
}
<STRING>"\\r" {
    buffer[buffer_len++] = '\r';
}
<STRING>"\\t" {
    buffer[buffer_len++] = '\t';
}
<STRING>"\\v" {
    buffer[buffer_len++] = '\v';
}
<STRING>"\\\\" {
    buffer[buffer_len++] = '\\';
}
<STRING>"\\\"" {
    buffer[buffer_len++] = '\"';
}
<STRING>"\n" {
    fprintf(stderr, "[ERRO LEXICO - %d:%d] String nao terminada.\n",
            yylloc.first_line, yylloc.first_column);
    exit(1);
}
<STRING><<EOF>> {
    fprintf(stderr, "[ERRO LEXICO - %d:%d] String nao terminada.\n",
            yylloc.first_line, yylloc.first_column);
    exit(1);
}
<STRING>"\\" {
    fprintf(stderr, "[ERRO LEXICO - %d:%d] Sequencia de escape nao reconhecida.\n",
            yylloc.first_line, yylloc.first_column);
    exit(1);
}
<STRING>"\"" {
    BEGIN INITIAL;
    buffer[buffer_len] = '\0';
    yylval.sval = strdup(buffer);
    return 259; // return STRING
}
<STRING>. {
    if (buffer_len < BUFFSIZE) {
        buffer[buffer_len++] = yytext[0];
    } else {
        fprintf(stderr, "[ERRO LEXICO - %d:%d] String maior do que o tamanho maximo permitido (%d).\n",
                yylloc.first_line, yylloc.first_column, BUFFSIZE);
        exit(1);
    }
}


"/*" { ++comment_level; BEGIN COMMENT; }
<COMMENT>"/*" { ++comment_level; }
<COMMENT>"*/" { if (--comment_level == 0) { BEGIN INITIAL; } }
<COMMENT><<EOF>> {;
    fprintf(stderr, "[ERRO LEXICO - %d:%d] Comentario nao terminado.\n",
            yylloc.first_line, yylloc.first_column);
    exit(1);
}
<COMMENT>. { }

<<EOF>> { return EOF; }

. {fprintf(stderr," Caracter invalido \n"); exit(1);}

%%
