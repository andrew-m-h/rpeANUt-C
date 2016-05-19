#ifndef PARSER_H
#define PARSER_H

#include <stdint.h>
#include <stdio.h>

int yylex();
int yyparse();
FILE *yyin;
void yyerror(const char *s);

typedef enum {
    REG0,
    REG1,
    REG2,
    REG3,
    REG4,
    REG5,
    REG6,
    REG7,
    SP,
    SR,
    PC,
    ONE,
    ZERO,
    MONE,
} REGISTER;

typedef enum {
    ADD,
    SUB,
    MULT,
    DIV,
    MOD,
    OR,
    AND,
    XOR,
    ROTATE
} TERNARYOPERATION;

typedef enum {
    NEG=ROTATE+1,
    NOT,
    JUMPZ,
    JUMPNZ,
    JUMPN,
    MOVE,
    SET,
    RESET,
    CALL,
    POP,
    PUSH,
    JUMP,
    TRAP,
    RETURN,
    HALT,
    BLOCK,
    LABLEDEF,
    INTLABLEDEF,
    LOAD_ABS,
    LOAD_IMM,
    LOAD_IND,
    LOAD_BASE,
    STORE_ABS,
    STORE_IND,
    STORE_BASE
} OPERATION;

typedef enum {
    REG_T,
    LABLE_T,
    IMMEDIATEINT_T,
    IMMEDIATESTRING_T,
    IMMEDIATELABLE_T,
    INT_T
} OPERAND_TYPE;

struct Operand {
    OPERAND_TYPE OpType;
    union {
        char* strVal;
        int32_t intVal;
    } Value;
};

struct Instruction {
    int32_t instruction;
    struct Operand op1;
    struct Operand op2;
    struct Operand op3;
};

#define INSTRUCTION(instr)                             \
    Instructions[InstrCount] = (struct Instruction*)malloc(sizeof(struct Instruction)); \
    Instructions[InstrCount]->instruction=instr

#define STROP1(op, val) Instructions[InstrCount]->op1.OpType = op; \
    Instructions[InstrCount]->op1.Value.strVal = val

#define INTOP1(op, val) Instructions[InstrCount]->op1.OpType = op;      \
    Instructions[InstrCount]->op1.Value.intVal = val

#define STROP2(op, val) Instructions[InstrCount]->op2.OpType = op;      \
    Instructions[InstrCount]->op2.Value.strVal = val

#define INTOP2(op, val) Instructions[InstrCount]->op2.OpType = op;      \
    Instructions[InstrCount]->op2.Value.intVal = val

#define STROP3(op, val) Instructions[InstrCount]->op3.OpType = op;      \
    Instructions[InstrCount]->op3.Value.strVal = val

#define INTOP3(op, val) Instructions[InstrCount]->op3.OpType = op;      \
    Instructions[InstrCount]->op3.Value.intVal = val

#define ADDRESSABLE_MEMORY 0x10000

extern struct Instruction * Instructions[ADDRESSABLE_MEMORY];
extern int32_t InstrCount;

#endif //PARSER_H
