#ifndef EMULATE_H
#define EMULATE_H

#include <stdint.h>

void emulate();
void execute(int32_t instruction);
void checkInterrupts(void);
void setIOFlags(void);

#endif //EMULATE_H
