#include <stdint.h>
#include <stdlib.h>
#include <search.h>
#include <string.h>
#include "parser.h"
#include "assemble.h"

const int32_t addcode = 0x10000000;
const int32_t subcode = 0x20000000;
const int32_t multcode = 0x30000000;
const int32_t divcode = 0x40000000;
const int32_t modcode = 0x50000000;
const int32_t andcode = 0x60000000;
const int32_t orcode = 0x70000000;
const int32_t xorcode = 0x80000000;
const int32_t rotatecode = 0xE0000000;

const int32_t negcode = 0xA0000000;
const int32_t notcode = 0xA1000000;
const int32_t movecode = 0xA2000000;

const int32_t jumpzcode = 0xA4100000;
const int32_t jumpncode = 0xA4200000;
const int32_t jumpnzcode = 0xA4300000;
const int32_t jumpcode = 0xA4000000;

const int32_t callcode = 0xA3000000;
const int32_t pushcode = 0xA6000000;
const int32_t popcode = 0xA6100000;
const int32_t returncode = 0xA3010000;
const int32_t trapcode = 0xA3020000;
const int32_t resetcode = 0xA5000000;
const int32_t setcode = 0xA5100000;
const int32_t haltcode = 0x00000000;

const int32_t loadImmcode = 0xC0000000;
const int32_t loadAbscode = 0xC1000000;
const int32_t loadIndcode = 0xC2000000;
const int32_t loadBasDispcode = 0xC3000000;
const int32_t storeAbscode = 0xD1000000;
const int32_t storeIndcode = 0xD2000000;
const int32_t storeBasDispcode = 0xD3000000;

volatile int memLoc = 0;

char* keys[ADDRESSABLE_MEMORY]; //each lable is a key to these values
int values[ADDRESSABLE_MEMORY]; //the memory locations where each lable is defined
//up to 500 invocations of each lable.
//These lists store their length as the first element
//These are the locations in the instruction buffer where each invocation is
int instrCounts[ADDRESSABLE_MEMORY][501];
//These are the locations in the output buffer where each instruction is (the instructions to be edited)
int memLocs[ADDRESSABLE_MEMORY][501];
int lableCounter = 0; //incrementing index for each of these arrays;

int assemble(struct Instruction* instructions[], int len, int32_t * buff){
    hcreate(ADDRESSABLE_MEMORY*2);

    for (int i = 0; i < len; i++){
        char * lableDef;
        ENTRY e, *ep;
        int j;
        switch (instructions[i]->instruction){
        case LABLEDEF:
            lableDef = instructions[i]->op1.Value.strVal;
            e.key = lableDef;
            ep = hsearch(e, FIND);
            if (ep == NULL){
                e.data = (void*) lableCounter;
                hsearch(e, ENTER);
                keys[lableCounter] = lableDef;
                values[lableCounter++] = memLoc;
            } else {
                values[(int)ep->data] = memLoc;
            }
            break;
        case INTLABLEDEF:
            memLoc = instructions[i]->op1.Value.intVal;
            break;
        case BLOCK:
            switch(instructions[i]->op3.OpType){
            case INT_T:
                memLoc += instructions[i]->op3.Value.intVal;
                break;
            case IMMEDIATEINT_T:
                buff[memLoc++] = instructions[i]->op3.Value.intVal;
                break;
            case IMMEDIATESTRING_T:
                j = 0;
                while (instructions[i]->op3.Value.strVal[j]){
                    buff[memLoc++] = instructions[i]->op3.Value.strVal[j++];
                }
                buff[memLoc++] = 0;
                break;
            default:
                fprintf(stderr, "invalid argument to block\n");
                exit(1);
            }
            break;
        case ADD:
            buff[memLoc] =
                emitTernary(addcode, i, instructions[i]->op1, instructions[i]->op2, instructions[i]->op3);
            memLoc++;
            break;
        case SUB:
            buff[memLoc] =
                emitTernary(subcode, i, instructions[i]->op1, instructions[i]->op2, instructions[i]->op3);
            memLoc++;
            break;
        case MULT:
            buff[memLoc] =
                emitTernary(multcode, i, instructions[i]->op1, instructions[i]->op2, instructions[i]->op3);
            memLoc++;
            break;
        case DIV:
            buff[memLoc] =
                emitTernary(divcode, i, instructions[i]->op1, instructions[i]->op2, instructions[i]->op3);
            memLoc++;
            break;
        case MOD:
            buff[memLoc] =
                emitTernary(modcode, i, instructions[i]->op1, instructions[i]->op2, instructions[i]->op3);
            memLoc++;
            break;
        case AND:
            buff[memLoc] =
                emitTernary(andcode, i, instructions[i]->op1, instructions[i]->op2, instructions[i]->op3);
            memLoc++;
            break;
        case OR:
            buff[memLoc] =
                emitTernary(orcode, i, instructions[i]->op1, instructions[i]->op2, instructions[i]->op3);
            memLoc++;
            break;
        case XOR:
            buff[memLoc] =
                emitTernary(xorcode, i, instructions[i]->op1, instructions[i]->op2, instructions[i]->op3);
            memLoc++;
            break;
        case ROTATE:
            buff[memLoc] =
                emitTernary(rotatecode, i, instructions[i]->op1, instructions[i]->op2, instructions[i]->op3);
            memLoc++;
            break;
        case NEG:
            buff[memLoc] =
                emitBinary(negcode, i, instructions[i]->op2, instructions[i]->op3);
            memLoc++;
            break;
        case NOT:
            buff[memLoc] =
                emitBinary(notcode, i, instructions[i]->op2, instructions[i]->op3);
            memLoc++;
            break;
        case MOVE:
            buff[memLoc] =
                emitBinary(movecode, i, instructions[i]->op2, instructions[i]->op3);
            memLoc++;
            break;
        case JUMPZ:
            buff[memLoc] =
                emitCondJump(jumpzcode, i, instructions[i]->op2, instructions[i]->op3);
            memLoc++;
            break;
        case JUMPN:
            buff[memLoc] =
                emitCondJump(jumpncode, i, instructions[i]->op2, instructions[i]->op3);
            memLoc++;
            break;
        case JUMPNZ:
            buff[memLoc] =
                emitCondJump(jumpnzcode, i, instructions[i]->op2, instructions[i]->op3);
            memLoc++;
            break;
        case JUMP:
            buff[memLoc] = jumpcode;
            switch(instructions[i]->op3.OpType){
            case LABLE_T:
                updateTable(instructions[i]->op3.Value.strVal, i);
                break;
            case INT_T:
                buff[memLoc] |= 0xFFFF & instructions[i]->op3.Value.intVal;
                break;
            default:
                fprintf(stderr, "jump must have either a decimal/hex/binary value or a lable");
                exit(1);
            }

            memLoc++;
            break;
        case CALL:
            buff[memLoc] = callcode;
            updateTable(instructions[i]->op3.Value.strVal, i);
            memLoc++;
            break;
        case RETURN:
            buff[memLoc++] = returncode;
            break;
        case TRAP:
            buff[memLoc++] = trapcode;
            break;
        case RESET:
            buff[memLoc++] = resetcode | (instructions[i]->op3.Value.intVal << 16);
            break;
        case SET:
            buff[memLoc++] = setcode | (instructions[i]->op3.Value.intVal << 16);
            break;
        case PUSH:
            buff[memLoc] =
                emitUnitary(pushcode, i, instructions[i]->op3);
            memLoc++;
            break;
        case POP:
            buff[memLoc++] = popcode | (instructions[i]->op3.Value.intVal << 16);
            break;
        case HALT:
            buff[memLoc++] = haltcode;
            break;
        case LOAD_ABS:
            buff[memLoc] = emitLoadAbs(i, instructions[i]->op1, instructions[i]->op2);
            memLoc++;
            break;
        case LOAD_IMM:
            buff[memLoc] = emitLoadImm(i, instructions[i]->op1, instructions[i]->op2);
            memLoc++;
            break;
        case LOAD_IND:
            buff[memLoc] = emitLoadInd(instructions[i]->op1, instructions[i]->op2);
            memLoc++;
            break;
        case LOAD_BASE:
            buff[memLoc] = emitLoadBase(i, instructions[i]->op1, instructions[i]->op2, instructions[i]->op3);
            memLoc++;
            break;
        case STORE_ABS:
            buff[memLoc] = emitStoreAbs(i, instructions[i]->op1, instructions[i]->op2);
            memLoc++;
            break;
        case STORE_IND:
            buff[memLoc] = emitStoreInd(instructions[i]->op1, instructions[i]->op2);
            memLoc++;
            break;
        case STORE_BASE:
            buff[memLoc] = emitStoreBase(i, instructions[i]->op1, instructions[i]->op2, instructions[i]->op3);
            memLoc++;
            break;
        default: ;
        }
    }

    resolveLables(instructions, buff);

    hdestroy();
    return memLoc;
}

void resolveLables(struct Instruction* instructions[], int32_t buff[]){
    for (int addr = 0; addr < lableCounter; addr++){
        for (int i = 1; i <= instrCounts[addr][0]; i++){
            int memLocation = memLocs[addr][i];
            int instrCount = instrCounts[addr][i];
            int32_t instruction = buff[memLocation];

            switch (instructions[instrCount]->instruction){
            case JUMP: break;
            case JUMPZ: break;
            case JUMPN: break;
            case JUMPNZ: break;
            case CALL: break;
            case LOAD_ABS: break;
            case LOAD_IND: break;
            case LOAD_IMM: break;
            case LOAD_BASE: break;
            case STORE_ABS: break;
            case STORE_IND: break;
            case STORE_BASE: break;
            default:
                if (instructions[instrCount]->op1.OpType == LABLE_T ||
                    instructions[instrCount]->op1.OpType == IMMEDIATELABLE_T){
                    instruction |= 0x0E000000; //lable converted to immediate
                } else if (instructions[instrCount]->op2.OpType == LABLE_T ||
                           instructions[instrCount]->op2.OpType == IMMEDIATELABLE_T){
                    instruction |= 0x00E00000;
                } else if (instructions[instrCount]->op3.OpType == LABLE_T ||
                           instructions[instrCount]->op3.OpType == IMMEDIATELABLE_T){
                    instruction |= 0x000E0000;
                }
            }
            buff[memLocation] = instruction | values[addr];
        }
    }
}

int32_t emitLoadImm(int instrCount, struct Operand op1, struct Operand op2){
    int32_t instr = loadImmcode;

    switch (op1.OpType){
    case IMMEDIATELABLE_T:
        updateTable(op1.Value.strVal, instrCount);
        break;
    case IMMEDIATEINT_T:
        instr |= 0xFFFF & op1.Value.intVal;
        break;
    default: fprintf(stderr, "Immediate Load emmit error\n");
    }

    switch (op2.OpType){
    case REG_T:
        instr |= op2.Value.intVal << 16;
        break;
    default: fprintf(stderr, "Immediate Load emmit error\n");
    }

    return instr;
}

int32_t emitLoadAbs(int instrCount, struct Operand op1, struct Operand op2){
    int32_t instr = loadAbscode;
    switch (op1.OpType){
    case LABLE_T:
        updateTable(op1.Value.strVal, instrCount);
        break;
    case INT_T:
        instr |= 0xFFFF & op1.Value.intVal;
        break;
    default: fprintf(stderr, "Absolute Load emmit error\n");
    }

    switch (op2.OpType){
    case REG_T:
        instr |= op2.Value.intVal << 16;
        break;
    default: fprintf(stderr, "Absolute Load emmit error\n");
    }

    return instr;
}

int32_t emitLoadInd(struct Operand op1, struct Operand op2){
    int32_t instr = loadIndcode;

    switch (op1.OpType){
    case REG_T:
        instr |= (op1.Value.intVal << 20);
        break;
    default: fprintf(stderr, "Indirect Load emmit error\n");
    }

    switch (op2.OpType){
    case REG_T:
        instr |= (op2.Value.intVal << 16);
        break;
    default: fprintf(stderr, "Indirect Load emmit error\n");
    }

    return instr;
}

int32_t emitLoadBase(int instrCount, struct Operand op1, struct Operand op2, struct Operand op3){
    int32_t instr = loadBasDispcode;

    switch (op1.OpType){
    case REG_T:
        instr |= (op1.Value.intVal << 20);
        break;
    default: fprintf(stderr, "Base + Offset Load emmit error\n");
    }

    switch (op2.OpType){
    case IMMEDIATEINT_T:
        instr |= 0xFFFF & op2.Value.intVal;
        break;
    case IMMEDIATELABLE_T:
        updateTable(op2.Value.strVal, instrCount);
        break;
    default: fprintf(stderr, "Base + Offset Load emmit error\n");
    }

    switch (op3.OpType){
    case REG_T:
        instr |= (op3.Value.intVal << 16);
        break;
    default: fprintf(stderr, "Base + Offset Load emmit error\n");
    }

    return instr;
}

int32_t emitStoreAbs(int instrCount, struct Operand op1, struct Operand op2){
    int32_t instr = storeAbscode;

    switch (op1.OpType){
    case REG_T:
        instr |= op1.Value.intVal << 20;
        break;
    default: fprintf(stderr, "Absolute Store emmit error\n");
    }

    switch (op2.OpType){
    case LABLE_T:
        updateTable(op2.Value.strVal, instrCount);
        break;
    case INT_T:
        instr |= 0xFFFF & op2.Value.intVal;
        break;
    default: fprintf(stderr, "Absolute Store emmit error\n");
    }

    return instr;
}

int32_t emitStoreInd(struct Operand op1, struct Operand op2){
    int32_t instr = storeIndcode;

    switch (op1.OpType){
    case REG_T:
        instr |= op1.Value.intVal << 20;
        break;
    default: fprintf(stderr, "Indirect Store emmit error\n");
    }

    switch (op2.OpType){
    case REG_T:
        instr |= op2.Value.intVal << 16;
        break;
    default: fprintf(stderr, "Indirect Store emmit error\n");
    }

    return instr;
}

int32_t emitStoreBase(int instrCount, struct Operand op1, struct Operand op2, struct Operand op3){
    int32_t instr = storeBasDispcode;

    switch (op1.OpType){
    case REG_T:
        instr |= op1.Value.intVal << 20;
        break;
    default: fprintf(stderr, "Base + Offset Store emmit error\n");
    }

    switch (op2.OpType){
    case IMMEDIATEINT_T:
        instr |= 0xFFFF & op2.Value.intVal;
        break;
    case IMMEDIATELABLE_T:
        updateTable(op2.Value.strVal, instrCount);
        break;
    default: fprintf(stderr, "Base + Offset Store emmit error\n");
    }

    switch (op3.OpType){
    case REG_T:
        instr |= op3.Value.intVal << 16;
        break;
    default: fprintf(stderr, "Base + Offset Store emmit error\n");
    }

    return instr;
}

void updateTable(char* key, int instrCount){
    ENTRY e, *ep;
    e.key = key;
    ep = hsearch(e, FIND);
    if (ep == NULL){
        e.data = (void*) lableCounter;
        hsearch(e, ENTER);
        keys[lableCounter] = key;
        instrCounts[lableCounter][0] = 1;
        instrCounts[lableCounter][1] = instrCount;
        memLocs[lableCounter][0] = 1;
        memLocs[lableCounter++][1] = memLoc;
    } else {
        int addr = (int) ep->data;
        int len = instrCounts[addr][0]+1;
        instrCounts[addr][len] = instrCount;
        instrCounts[addr][0] = len;
        memLocs[addr][len] = memLoc;
        memLocs[addr][0] = len;
    }
}

int32_t emitTernary(int32_t instr, int instrCount, struct Operand op1, struct Operand op2, struct Operand op3){

    switch (op1.OpType){
    case REG_T: instr |= (op1.Value.intVal << 24); break;
    case IMMEDIATEINT_T:
        instr |= 0x0E000000;
        instr |= (0xFFFF & op1.Value.intVal);
        break;
    case IMMEDIATELABLE_T:
        updateTable(op1.Value.strVal, instrCount);
        break;
    default:
        fprintf(stderr, "add argument error\n");
        exit(1);
        break;
    }

    switch (op2.OpType){
    case REG_T: instr |= (op2.Value.intVal << 20); break;
    case IMMEDIATEINT_T:
        instr |= 0x00E00000;
        instr |= (0xFFFF & op2.Value.intVal);
        break;
    case IMMEDIATELABLE_T:
        updateTable(op2.Value.strVal, instrCount);
        break;
    default:
        fprintf(stderr, "add argument error\n");
        exit(1);
        break;
    }

    switch (op3.OpType){
    case REG_T:
        instr |= (op3.Value.intVal << 16);
        break;
    default:
        fprintf(stderr, "add argument error\n");
        exit(1);
        break;
    }

    return instr;
}

int32_t emitBinary(int32_t instr, int instrCount, struct Operand op2, struct Operand op3){
    switch (op2.OpType){
    case REG_T: instr |= (op2.Value.intVal << 20); break;
    case IMMEDIATEINT_T:
        instr |= 0x00E00000;
        instr |= 0xFFFF & op2.Value.intVal;
        break;
    case LABLE_T:
        updateTable(op2.Value.strVal, instrCount);
        break;
    case INT_T:
        instr |= 0xFFFF & op2.Value.intVal;
        break;
    default:
        fprintf(stderr, "add argument error\n");
        exit(1);
        break;
    }
    switch (op3.OpType){
    case REG_T:
        instr |= (op3.Value.intVal << 16);
        break;
    case LABLE_T:
        updateTable(op3.Value.strVal, instrCount);
        break;
    case INT_T:
        instr |= 0xFFFF & op3.Value.intVal;
        break;
    default:
        fprintf(stderr, "add argument error\n");
        exit(1);
        break;
    }
    return instr;
}

int32_t emitCondJump(int32_t instr, int instrCount, struct Operand op2, struct Operand op3){
    switch (op2.OpType){
    case REG_T: instr |= (op2.Value.intVal << 16); break;
    default:
        fprintf(stderr, "add argument error\n");
        exit(1);
    }

    switch (op3.OpType){
    case LABLE_T:
        updateTable(op3.Value.strVal, instrCount);
        break;
    case INT_T:
        instr |= 0xFFFF & op3.Value.intVal;
        break;
    default:
        fprintf(stderr, "add argument error\n");
        exit(1);
    }

    return instr;
}

int32_t emitUnitary(int32_t instr, int instrCount, struct Operand op3){
    switch (op3.OpType){
    case REG_T:
        instr |= (op3.Value.intVal << 16);
        break;
    case IMMEDIATEINT_T:
        instr |= 0x000E0000;
        instr |= (0xFFFF & op3.Value.intVal);
        break;
    case LABLE_T:
        updateTable(op3.Value.strVal, instrCount);
        break;
    default:
        fprintf(stderr, "add argument error\n");
        exit(1);
        break;
    }
    return instr;
}

void cleanup(){
    //strings passed from the tokenizer are malloc'd and need freeing
    //instructions are malloc'd and need freeing
    for (int i = 0; i < ADDRESSABLE_MEMORY; i++){
        if (Instructions[i]){
            free(Instructions[i]);
        }
    }
}
