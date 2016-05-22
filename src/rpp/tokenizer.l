%option noyywrap

%{
#include <string.h>
#include <stdlib.h>
#include <stdio.h>
#include "parser.tab.h"

#define YY_DECL int yylex()

extern int fileno(FILE *stream);

char* strdup(const char* str){
    char* out = (char*) malloc(strlen(str));
    strcpy(out, str);
    return out;
}

%}

%s MACROSTATE

%%

<INITIAL>#define[ \t]+  BEGIN(MACROSTATE); return LINE_MACRO;

[a-zA-Z0-9]+   yylval.sval = strdup(yytext); return LABLE;

<MACROSTATE>[ \t]+[a-zA-Z0-9 \t]+    yylval.sval = strdup(yytext+1); return EXPANSION;

<MACROSTATE>\n          BEGIN(INITIAL); return ENDL;

.              yylval.cval = yytext[0]; return CHAR; //catch-all
\n             yylval.cval = '\n'; return CHAR; //catch-all

%%