%{
    #include <stdio.h>
    #include <stdlib.h>
    #include <stdint.h>
    #include "parser.h"

    struct Instruction * Instructions[ADDRESSABLE_MEMORY];
    int32_t InstrCount = 0;

%}

%union {
    int32_t ival;
    char* sval;
    REGISTER regval;
    TERNARYOPERATION ternval;
}

%token <sval> LABLE
%token <sval> LABLEDEF_TOKEN
%token <ival> INTLABLEDEF_TOKEN

%token <ival> IMMEDIATEINT
%token <sval> IMMEDIATESTRING
%token <sval> IMMEDIATELABLE
%token <ival> INT

%token <regval> REG
%token <ternval> TERNOP
%token <opval> OP

%token NEG_TOKEN
%token NOT_TOKEN
%token JUMP_TOKEN
%token JUMPZ_TOKEN
%token JUMPNZ_TOKEN
%token JUMPN_TOKEN
%token MOVE_TOKEN
%token SET_TOKEN
%token RESET_TOKEN
%token CALL_TOKEN
%token POP_TOKEN
%token PUSH_TOKEN
%token TRAP_TOKEN
%token RETURN_TOKEN
%token HALT_TOKEN
%token BLOCK_TOKEN
%token LOAD_TOKEN
%token STORE_TOKEN

%token ENDL

%%

file: expression file
    | expression
    ;

expression:
    ENDLS
    | LABLEDEF_TOKEN                      {INSTRUCTION(LABLEDEF); STROP1(LABLE_T, $1); InstrCount++;}
    | INTLABLEDEF_TOKEN                   {INSTRUCTION(INTLABLEDEF); INTOP1(INT_T, $1); InstrCount++;}
    | ternaryoperation ENDLS
    | operation ENDLS

ternaryoperation:
    TERNOP REG REG REG               {INSTRUCTION($1); INTOP1(REG_T, $2); INTOP2(REG_T, $3); INTOP3(REG_T, $4); InstrCount++;}
    | TERNOP REG IMMEDIATELABLE REG  {INSTRUCTION($1); INTOP1(REG_T, $2); STROP2(IMMEDIATELABLE_T, $3); INTOP3(REG_T, $4); InstrCount++;}
    | TERNOP REG IMMEDIATEINT REG    {INSTRUCTION($1); INTOP1(REG_T, $2); INTOP2(IMMEDIATEINT_T, $3); INTOP3(REG_T, $4); InstrCount++;}
    | TERNOP IMMEDIATEINT REG REG    {INSTRUCTION($1); INTOP1(IMMEDIATEINT_T, $2); INTOP2(REG_T, $3); INTOP3(REG_T, $4); InstrCount++;}
    ;

operation:
    NEG_TOKEN REG REG               {INSTRUCTION(NEG); INTOP2(REG_T, $2); INTOP3(REG_T, $3); InstrCount++;}
    | NEG_TOKEN IMMEDIATEINT REG    {INSTRUCTION(NEG); INTOP2(IMMEDIATEINT_T, $2); INTOP3(REG_T, $3); InstrCount++;}
    | NEG_TOKEN IMMEDIATELABLE REG  {INSTRUCTION(NEG); STROP2(IMMEDIATELABLE_T, $2); INTOP3(REG_T, $3); InstrCount++;}

    | NOT_TOKEN REG REG             {INSTRUCTION(NOT); INTOP2(REG_T, $2); INTOP3(REG_T, $3); InstrCount++;}
    | NOT_TOKEN IMMEDIATEINT REG    {INSTRUCTION(NOT); INTOP2(IMMEDIATEINT_T, $2); INTOP3(REG_T, $3); InstrCount++;}
    | NOT_TOKEN IMMEDIATELABLE REG  {INSTRUCTION(NOT); STROP2(IMMEDIATELABLE_T, $2); INTOP3(REG_T, $3); InstrCount++;}

    | JUMP_TOKEN INT                {INSTRUCTION(JUMP); INTOP3(INT_T, $2); InstrCount++;}
    | JUMP_TOKEN LABLE              {INSTRUCTION(JUMP); STROP3(LABLE_T, $2); InstrCount++;}

    | JUMPZ_TOKEN REG INT           {INSTRUCTION(JUMPZ); INTOP2(REG_T, $2); INTOP3(INT_T, $3); InstrCount++;}
    | JUMPZ_TOKEN REG LABLE         {INSTRUCTION(JUMPZ); INTOP2(REG_T, $2); STROP3(LABLE_T, $3); InstrCount++;}

    | JUMPNZ_TOKEN REG INT          {INSTRUCTION(JUMPNZ); INTOP2(REG_T, $2); INTOP3(INT_T, $3); InstrCount++;}
    | JUMPNZ_TOKEN REG LABLE        {INSTRUCTION(JUMPNZ); INTOP2(REG_T, $2); STROP3(LABLE_T, $3); InstrCount++;}

    | JUMPN_TOKEN REG INT           {INSTRUCTION(JUMPN); INTOP2(REG_T, $2); INTOP3(INT_T, $3); InstrCount++;}
    | JUMPN_TOKEN REG LABLE         {INSTRUCTION(JUMPN); INTOP2(REG_T, $2); STROP3(LABLE_T, $3); InstrCount++;}

    | MOVE_TOKEN REG REG            {INSTRUCTION(MOVE); INTOP2(REG_T, $2); INTOP3(REG_T, $3); InstrCount++;}

    | CALL_TOKEN LABLE              {INSTRUCTION(CALL); STROP3(LABLE_T, $2); InstrCount++;}
    | CALL_TOKEN INT           {INSTRUCTION(CALL); INTOP3(INT_T, $2); InstrCount++;}

    | RETURN_TOKEN                  {INSTRUCTION(RETURN); InstrCount++;}

    | TRAP_TOKEN                    {INSTRUCTION(TRAP); InstrCount++;}

    | RESET_TOKEN INT               {INSTRUCTION(RESET); INTOP3(INT_T, $2); InstrCount++;}

    | SET_TOKEN INT                 {INSTRUCTION(SET); INTOP3(INT_T, $2); InstrCount++;}

    | PUSH_TOKEN IMMEDIATELABLE     {INSTRUCTION(PUSH); STROP3(IMMEDIATELABLE_T, $2); InstrCount++;}
    | PUSH_TOKEN IMMEDIATEINT       {INSTRUCTION(PUSH); INTOP3(IMMEDIATEINT_T, $2); InstrCount++;}
    | PUSH_TOKEN REG                {INSTRUCTION(PUSH); INTOP3(REG_T, $2); InstrCount++;}

    | POP_TOKEN REG                 {INSTRUCTION(POP); INTOP3(REG_T, $2); InstrCount++;}

    | LOAD_TOKEN IMMEDIATELABLE REG {INSTRUCTION(LOAD_IMM); STROP1(IMMEDIATELABLE_T, $2); INTOP2(REG_T, $3); InstrCount++;}
    | LOAD_TOKEN IMMEDIATEINT REG   {INSTRUCTION(LOAD_IMM); INTOP1(IMMEDIATEINT_T, $2); INTOP2(REG_T, $3); InstrCount++;}

    | LOAD_TOKEN LABLE REG      {INSTRUCTION(LOAD_ABS); STROP1(LABLE_T, $2); INTOP2(REG_T, $3); InstrCount++;}
    | LOAD_TOKEN INT REG        {INSTRUCTION(LOAD_ABS); INTOP1(INT_T, $2); INTOP2(REG_T, $3); InstrCount++;}

    | LOAD_TOKEN REG REG        {INSTRUCTION(LOAD_IND); INTOP1(REG_T, $2); INTOP2(REG_T, $3); InstrCount++;}

    | LOAD_TOKEN REG IMMEDIATEINT REG    {INSTRUCTION(LOAD_BASE); INTOP1(REG_T, $2); INTOP2(IMMEDIATEINT_T, $3); INTOP3(REG_T, $4); InstrCount++;}
    | LOAD_TOKEN REG IMMEDIATELABLE REG  {INSTRUCTION(LOAD_BASE); INTOP1(REG_T, $2); STROP2(IMMEDIATELABLE_T, $3); INTOP3(REG_T, $4); InstrCount++;}

    | STORE_TOKEN REG LABLE               {INSTRUCTION(STORE_ABS); INTOP1(REG_T, $2); STROP2(LABLE_T, $3); InstrCount++;}
    | STORE_TOKEN REG INT                 {INSTRUCTION(STORE_ABS); INTOP1(REG_T, $2); INTOP2(INT_T, $3); InstrCount++;}

    | STORE_TOKEN REG REG                 {INSTRUCTION(STORE_IND); INTOP1(REG_T, $2); INTOP2(REG_T, $3); InstrCount++;}

    | STORE_TOKEN REG IMMEDIATEINT REG   {INSTRUCTION(STORE_BASE); INTOP1(REG_T, $2); INTOP2(IMMEDIATEINT_T, $3); INTOP3(REG_T, $4); InstrCount++;}
    | STORE_TOKEN REG IMMEDIATELABLE REG {INSTRUCTION(STORE_BASE); INTOP1(REG_T, $2); STROP2(IMMEDIATELABLE_T, $3); INTOP3(REG_T, $4); InstrCount++;}

    | HALT_TOKEN                         {INSTRUCTION(HALT); InstrCount++;}

    | BLOCK_TOKEN IMMEDIATEINT            {INSTRUCTION(BLOCK); INTOP3(IMMEDIATEINT_T, $2); InstrCount++;}
    | BLOCK_TOKEN INT                     {INSTRUCTION(BLOCK); INTOP3(INT_T, $2); InstrCount++;}
    | BLOCK_TOKEN IMMEDIATESTRING         {INSTRUCTION(BLOCK); STROP3(IMMEDIATESTRING_T, $2); InstrCount++;}
    ;

ENDLS:
    ENDLS ENDL
    | ENDL
    ;


%%

void yyerror(const char *s) {
    printf ("Parse Error! Message: %s\n", s);
    // might as well halt now:
    exit(-1);
}
