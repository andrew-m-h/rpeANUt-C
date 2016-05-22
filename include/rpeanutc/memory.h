#ifndef MEMORY_H
#define MEMORY_H

#include <stdint.h>

#define ADDRESSABLE_MEMORY 0x10000

extern int32_t Memory[ADDRESSABLE_MEMORY];

int32_t readMem(int32_t addr);
void writeMem(int32_t addr, int32_t cell);

#define BUFFERSIZE  1

extern char stdinBuff[BUFFERSIZE];
#endif //MEMORY_H
