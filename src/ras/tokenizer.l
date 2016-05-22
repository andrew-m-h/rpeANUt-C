%option noyywrap

%{
#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>
#include <string.h>
#include "parser.h"
#include "parser.tab.h"

#define YY_DECL int yylex()

extern int fileno(FILE *stream);

char* strdup(const char* str){
    char* out = (char*) malloc(strlen(str));
    int i = 0;
    while (str[i] != ' ' && str[i] != '\t' && str[i] != ':' && str[i]){
        out[i] = str[i];
        i++;
    }
    out[i] = 0;
    return out;
}

%}

%%

;.*

R0    yylval.regval = REG0; return REG;
R1    yylval.regval = REG1; return REG;
R2    yylval.regval = REG2; return REG;
R3    yylval.regval = REG3; return REG;
R4    yylval.regval = REG4; return REG;
R5    yylval.regval = REG5; return REG;
R6    yylval.regval = REG6; return REG;
R7    yylval.regval = REG7; return REG;
SP    yylval.regval = SP; return REG;
SR    yylval.regval = SR; return REG;
PC    yylval.regval = PC; return REG;
ONE    yylval.regval = ONE; return REG;
ZERO    yylval.regval = ZERO; return REG;
MONE    yylval.regval = MONE; return REG;

r0    yylval.regval = REG0; return REG;
r1    yylval.regval = REG1; return REG;
r2    yylval.regval = REG2; return REG;
r3    yylval.regval = REG3; return REG;
r4    yylval.regval = REG4; return REG;
r5    yylval.regval = REG5; return REG;
r6    yylval.regval = REG6; return REG;
r7    yylval.regval = REG7; return REG;
sp    yylval.regval = SP; return REG;
sr    yylval.regval = SR; return REG;
pc    yylval.regval = PC; return REG;
one    yylval.regval = ONE; return REG;
zero    yylval.regval = ZERO; return REG;
mone    yylval.regval = MONE; return REG;

OF   yylval.ival = 0; return INT;
IM   yylval.ival = 1; return INT;
TI   yylval.ival = 2; return INT;

of   yylval.ival = 0; return INT;
im   yylval.ival = 1; return INT;
ti   yylval.ival = 2; return INT;


ADD    yylval.ternval = ADD; return TERNOP;
SUB    yylval.ternval = SUB; return TERNOP;
MULT    yylval.ternval = MULT; return TERNOP;
DIV    yylval.ternval = DIV; return TERNOP;
MOD    yylval.ternval = MOD; return TERNOP;
OR    yylval.ternval = OR; return TERNOP;
AND    yylval.ternval = AND; return TERNOP;
XOR    yylval.ternval = XOR; return TERNOP;
ROTATE    yylval.ternval = ROTATE; return TERNOP;

add    yylval.ternval = ADD; return TERNOP;
sub    yylval.ternval = SUB; return TERNOP;
mult    yylval.ternval = MULT; return TERNOP;
div    yylval.ternval = DIV; return TERNOP;
mod    yylval.ternval = MOD; return TERNOP;
or    yylval.ternval = OR; return TERNOP;
and    yylval.ternval = AND; return TERNOP;
xor    yylval.ternval = XOR; return TERNOP;
rotate    yylval.ternval = ROTATE; return TERNOP;

NEG      return NEG_TOKEN;
neg      return NEG_TOKEN;
NOT      return NOT_TOKEN;
not      return NOT_TOKEN;
JUMPZ      return JUMPZ_TOKEN;
jumpz      return JUMPZ_TOKEN;
JUMPNZ      return JUMPNZ_TOKEN;
jumpnz      return JUMPNZ_TOKEN;
JUMPN      return JUMPN_TOKEN;
jumpn      return JUMPN_TOKEN;
MOVE      return MOVE_TOKEN;
move      return MOVE_TOKEN;
SET      return SET_TOKEN;
set      return SET_TOKEN;
RESET      return RESET_TOKEN;
reset      return RESET_TOKEN;
CALL      return CALL_TOKEN;
call      return CALL_TOKEN;
POP      return POP_TOKEN;
pop      return POP_TOKEN;
PUSH      return PUSH_TOKEN;
push      return PUSH_TOKEN;
JUMP      return JUMP_TOKEN;
jump      return JUMP_TOKEN;
TRAP      return TRAP_TOKEN;
trap      return TRAP_TOKEN;
RETURN      return RETURN_TOKEN;
return      return RETURN_TOKEN;
HALT      return HALT_TOKEN;
halt      return HALT_TOKEN;
BLOCK      return BLOCK_TOKEN;
block      return BLOCK_TOKEN;
LOAD      return LOAD_TOKEN;
load      return LOAD_TOKEN;
STORE      return STORE_TOKEN;
store      return STORE_TOKEN;

[ \t]+

[\n]+    return ENDL;

#-?[0-9]+        sscanf(yytext, "#%d", &yylval.ival); return IMMEDIATEINT;
#0x[0-9A-Fa-f]+  sscanf(yytext, "#%x", &yylval.ival); return IMMEDIATEINT;
#0b[0-1]+        sscanf(yytext, "#0b%i", &yylval.ival); return IMMEDIATEINT;
#'.'             yylval.ival = (int32_t) yytext[2]; return IMMEDIATEINT;
#\"[a-zA-Z0-9]+\"    yylval.sval = strdup(yytext+1); return IMMEDIATESTRING;
#[a-zA-Z0-9]+     yylval.sval = strdup(yytext+1); return IMMEDIATELABLE;

0x[0-9A-Fa-f]+:        sscanf(yytext, "%x:", &yylval.ival); return INTLABLEDEF_TOKEN;
0b[0-1]+:              sscanf(yytext, "0b%i:", &yylval.ival); return INTLABLEDEF_TOKEN;
[0-9]+:                sscanf(yytext, "%d:", &yylval.ival); return INTLABLEDEF_TOKEN;
[a-zA-Z0-9]+[ \t]*:    yylval.sval = strdup(yytext); return LABLEDEF_TOKEN;

[0-9]+          sscanf(yytext, "%d", &yylval.ival); return INT;
0x[0-9A-Fa-f]+  sscanf(yytext, "%x", &yylval.ival); return INT;
0b[0-1]+        sscanf(yytext, "0b%i", &yylval.ival); return INT;
'.'             yylval.ival = (int32_t) yytext[1]; return INT;

[a-zA-Z0-9]+    yylval.sval = strdup(yytext); return LABLE;

%%
