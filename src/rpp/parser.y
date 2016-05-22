%{
    #include <stdio.h>
    #include <stdlib.h>
    #include <string.h>
    #include <search.h>
    #include "parser.h"

    void insertDefinition(char * lable, char * expansion){
        ENTRY e;
        e.key = lable;
        e.data = (void*)expansion;
        hsearch(e, ENTER);
    }

    char* lookupLable(char * lable){
        ENTRY e, *ep;
        e.key = (void*) lable;
        ep = hsearch(e, FIND);
        if (ep == NULL){
            return lable;
        } else {
            return (char*)ep->data;
        }
    }

    char outputFile[FILE_LENGTH] = {0};
    int fileLen = 0;
%}

%union {
    char cval;
    char* sval;
}

%token <sval> MACRO_ARG
%token <sval> LABLE
%token <sval> EXPANSION
%token <cval> CHAR

%token LINE_MACRO
%token MACRO_BEGIN
%token MACRO_END
%token ENDL

%%

file:
    expression
    | file expression
    ;

expression:
    lineMacro
    | LABLE      {char * str = lookupLable($1); strcpy(outputFile + fileLen, str); fileLen += strlen(str);}
    | CHAR       {outputFile[fileLen++] = $1;}
    ;

lineMacro:
    LINE_MACRO LABLE EXPANSION ENDL    {insertDefinition($2, $3); strcpy(outputFile + fileLen, ";; macro defined\n"); fileLen+=17;}
    ;

%%

void yyerror(const char *s) {
    printf ("Parse Error! Message: %s\n", s);
    // might as well halt now:
    exit(-1);
}
