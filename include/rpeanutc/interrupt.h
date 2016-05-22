#ifndef INTERRUPT_H
#define INTERRUPT_H

#include <stdint.h>

#include "interrupt.h"

extern int MemoryFaultInterrupt;
extern int TrapInterrupt;
extern int KeyboardInterrupt;

extern const int32_t MemoryFault;
extern const int32_t IOInterrupt;
extern const int32_t Trap;
extern const int32_t Timer;

void checkKeyboard();

#endif // INTERRUPT_H
