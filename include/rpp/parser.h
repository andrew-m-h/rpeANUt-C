#ifndef PARSER_H
#define PARSER_H

#include <stdio.h>

int yylex();
int yyparse();
FILE *yyin;
void yyerror(const char *s);

#define FILE_LENGTH 10000000 //10 million character should suffice

extern char outputFile[FILE_LENGTH];
extern int fileLen;

#endif //PARSER_H
