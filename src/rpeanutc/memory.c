#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>

#include "memory.h"
#include "interrupt.h"

int32_t readMem(int32_t addr){
    if (addr >= ADDRESSABLE_MEMORY || addr < 0){
        MemoryFaultInterrupt = 1;
        return 0;
    } else if (addr == 0xFFF0){
        if (Memory[0xFFF1] == 0x1) {
            return (int32_t)getchar();
        }
        return 0;
    } else {
        return Memory[addr];
    }
}

void writeMem(int32_t addr, int32_t cell){
    if (addr >= ADDRESSABLE_MEMORY || addr < 0){
        MemoryFaultInterrupt = 1;
    } else if (addr == 0xFFF0){
        putchar(cell);
    } else {
        Memory[addr] = cell;
    }
}
