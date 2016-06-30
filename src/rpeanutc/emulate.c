#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>

#include <unistd.h>
#include <poll.h>

#include "memory.h"
#include "emulate.h"
#include "interrupt.h"

#define haltcode 0x0
#define addcode 0x1
#define subcode 0x2
#define multcode 0x3
#define divcode 0x4
#define modcode 0x5
#define andcode 0x6
#define orcode 0x7
#define xorcode 0x8
#define rotatecode 0xE

const int32_t MemoryFault = 0x0000;
const int32_t IOInterrupt = 0x0001;
const int32_t Trap = 0x0002;
const int32_t Timer = 0x0003;

int MemoryFaultInterrupt = 0;
int TrapInterrupt = 0;
int KeyboardInterrupt = 0;

const int32_t OF = 0x00000001;
const int32_t IM = 0x00000002;
const int32_t TI = 0x00000004;

//                     R0 ................ R7   SP    SR   PC  ONE ZERO MONE
int32_t registers[] = {0, 0, 0, 0, 0, 0, 0, 0, 0x7000, 0, 0x100, 1, 0, -1};
int32_t IR = 0;
#define SP registers[8]
#define SR registers[9]
#define PC registers[10]

int CycleCount = 0;

int32_t Memory[ADDRESSABLE_MEMORY];

void setIOFlags(void);

void emulate(){
    do {
        setIOFlags();
        IR = readMem(PC);
        PC++;
        execute(IR);
        if ((SR & TI) == TI){
            CycleCount++;
        } else {
            CycleCount = 0;
        }
        if (!(SR & IM)){
            checkInterrupts();
        }
    } while (IR != 0x00000000);
}

int32_t rotate (int32_t, int32_t);

#define CHECK_CONSTANT_REG(nib) if (nib > 0xA){                 \
        fprintf(stderr, "cannot write to constant register\n"); \
        exit(1);                                                \
    }


void execute (int32_t instruction){
    int32_t nibble0, nibble1, nibble2, nibble3;
    nibble0 = (instruction >> 28) & 0x0000000F;
    nibble1 = (instruction >> 24) & 0x0000000F;
    nibble2 = (instruction >> 20) & 0x0000000F;
    nibble3 = (instruction >> 16) & 0x0000000F;

    int32_t arg1, arg2, arg3;
    arg1 = nibble1 == 0xE ? (int16_t)(instruction & 0x0000FFFF) : registers[nibble1];
    arg2 = nibble2 == 0xE ? (int16_t)(instruction & 0x0000FFFF) : registers[nibble2];
    arg3 = nibble3 == 0xE ? (int16_t)(instruction & 0x0000FFFF) : registers[nibble3];

    switch (nibble0){ //check first nibble
    case haltcode:
        break;
    case addcode:
        CHECK_CONSTANT_REG(nibble3);
        registers[nibble3] = arg1 + arg2;
        break;
    case subcode:
        CHECK_CONSTANT_REG(nibble3);
        registers[nibble3] = arg1 - arg2;
        break;
    case multcode:
        CHECK_CONSTANT_REG(nibble3);
        registers[nibble3] = arg1 * arg2;
        break;
    case divcode:
        CHECK_CONSTANT_REG(nibble3);
        registers[nibble3] = arg1 / arg2;
        break;
    case modcode:
        CHECK_CONSTANT_REG(nibble3);
        registers[nibble3] = arg1 % arg2;
        break;
    case andcode:
        CHECK_CONSTANT_REG(nibble3);
        registers[nibble3] = arg1 & arg2;
        break;
    case orcode:
        CHECK_CONSTANT_REG(nibble3);
        registers[nibble3] = arg1 | arg2;
        break;
    case xorcode:
        CHECK_CONSTANT_REG(nibble3);
        registers[nibble3] = arg1 ^ arg2;
        break;
    case rotatecode:
        CHECK_CONSTANT_REG(nibble3);
        registers[nibble3] = rotate(arg2, arg1);
        break;
    case 0xA: ; //one of: neg, not, move, call, return, trap, jump, jumpz, jumpn, jumpnz, reset, set, push, pop
        switch (nibble1){
        case 0x0: //negate
            CHECK_CONSTANT_REG(nibble3);
            registers[nibble3] = - arg2;
            break;
        case 0x1: //not
            CHECK_CONSTANT_REG(nibble3);
            registers[nibble3] = ~ arg2;
            break;
        case 0x2: //move
            CHECK_CONSTANT_REG(nibble3);
            registers[nibble3] = arg2;
            break;
        case 0x3: //one of call, return trap
            switch (nibble3){
            case 0x0: //call
                writeMem(++SP, PC); //Memory[++SP] = PC;
                PC = instruction & 0x0000FFFF;
                break;
            case 0x1: //return
                PC = readMem(SP--); //PC = Memory[SP--];
                break;
            case 0x2: //trap
                TrapInterrupt = 1;
                break;
            default:
                fprintf(stderr, "Invalid instruction: %08x\n", instruction);
            }
            break;
        case 0x4: //one of: jump, jumpz, jumpn, jumpnz
            switch (nibble2){
            case 0x0: //jump
                PC = instruction & 0x0000FFFF;
                break;
            case 0x1: //jumpz
                PC = registers[nibble3] ? PC : instruction & 0x0000FFFF;
                break;
            case 0x2: //jumpn
                PC = (registers[nibble3] < 0) ? instruction & 0x0000FFFF : PC;
                break;
            case 0x3: //jumpnz
                PC = registers[nibble3] ? instruction & 0x0000FFFF : PC;
                break;
            default:
                fprintf(stderr, "Invalid instruction: %08x\n", instruction);
            }
            break;
        case 0x5: //one of: reset, set
            switch (nibble2){
            case 0x0: //reset
                SR = SR & ~(1 << nibble3);
                break;
            case 0x1: //set
                SR = SR | (1 << nibble3);
                break;
            default:
                fprintf(stderr, "Invalid instruction: %08x\n", instruction);
            }
            break;
        case 0x6: //one of: push, pop
            switch (nibble2){
            case 0x0: //push
                writeMem(++SP, arg3);//Memory[++SP] = arg3;
                break;
            case 0x1: //pop
                CHECK_CONSTANT_REG(nibble3);
                registers[nibble3] = readMem(SP--); //Memory[SP--];
                break;
            default:
                fprintf(stderr, "Invalid instruction: %08x\n", instruction);
            }
            break;
        default:
            fprintf(stderr, "Invalid instruction: %08x\n", instruction);
        }
        break;
    case 0xC: ; //load
        switch (nibble1){
        case 0x0: //immediate load
            CHECK_CONSTANT_REG(nibble3);
            registers[nibble3] = (int16_t)(instruction & 0x0000FFFF);
            break;
        case 0x1: //absolute load
            CHECK_CONSTANT_REG(nibble3);
            registers[nibble3] = readMem(instruction & 0x0000FFFF);
            break;
        case 0x2: //indirect load
            CHECK_CONSTANT_REG(nibble3);
            registers[nibble3] = readMem(registers[nibble2]);
            break;
        case 0x3: //base + disp load
            CHECK_CONSTANT_REG(nibble3);
            registers[nibble3] = readMem(registers[nibble2] + (int16_t)(instruction & 0x0000FFFF));
            break;
        default:
            fprintf(stderr, "Invalid instruction: %08x\n", instruction);
        }
        break;
    case 0xD: ; //store
        switch (nibble1){
        case 0x1: //absolute store
            writeMem(instruction & 0x0000FFFF, registers[nibble2]);
            break;
        case 0x2: //indirect store
            writeMem(registers[nibble3], registers[nibble2]);
            break;
        case 0x3: //base + disp store
            writeMem(registers[nibble3] + (int16_t)(instruction & 0x0000FFFF), registers[nibble2]);
            break;
        default:
            fprintf(stderr, "Invalid instruction: %08x\n", instruction);
        }
        break;
    default: ;
        fprintf(stderr, "Invalid instruction: %08x\n", instruction);
    }
}

int32_t rotate (int32_t value, int32_t count) {
    if (count >= 0){
        return (value<<count) | (value >> (32 - count));
    } else {
        count = -count;
        return (value>>count) | (value << (32 - count));
    }
}

void checkInterrupts(void){
    if (MemoryFaultInterrupt){
        MemoryFaultInterrupt = 0;
        Memory[++SP] = PC;
        PC = MemoryFault;
        SR |= IM;  //set IM bit
    } else if (KeyboardInterrupt && (Memory[0xFFF2] == 0x1)){
        KeyboardInterrupt = 0;
        Memory[++SP] = PC;
        PC = IOInterrupt;
        SR |= IM;  //set IM bit
    } else if (TrapInterrupt){
        TrapInterrupt = 0;
        Memory[++SP] = PC;
        PC = Trap;
        SR |= IM;  //set IM bit
    } else if (CycleCount % 1000 == 0 && ((SR & TI) == TI)){
        Memory[++SP] = PC;
        PC = Timer;
        SR |= IM;
    }
}

struct pollfd stdin_poll = {.fd = STDIN_FILENO
                            , .events = POLLIN | POLLRDBAND | POLLRDNORM | POLLPRI };

void setIOFlags(void){

    if (poll(&stdin_poll, 1, 0)){
        if (!(SR & IM)){
            KeyboardInterrupt = 1;
        }
        Memory[0xFFF1] = 0x1;
    } else {
        Memory[0xFFF1] = 0x0;
    }
}
