#ifndef ASSEMBLE_H
#define ASSEMBLE_H

#include <stdint.h>
#include "parser.h"

int assemble(struct Instruction**, int, int32_t*);

int32_t emitTernary(int32_t, int, struct Operand, struct Operand, struct Operand);

/*
int32_t emitNeg(int, struct Operand, struct Operand);
int32_t emitNot(int, struct Operand, struct Operand);
int32_t emitMove(struct Operand, struct Operand);
int32_t emitCall(int, struct Operand);
int32_t emitReturn();
int32_t emitTrap();
int32_t emitReset(struct Operand);
int32_t emitSet(struct Operand);
int32_t emitPush(int, struct Operand);
int32_t emitPop(struct Operand);
int32_t emitLoadImm(int, struct Operand, struct Operand);
int32_t emitLoadAbs(int, struct Operand, struct Operand);
int32_t emitLoadInd(struct Operand, struct Operand);
int32_t emitLoadBase(int, struct Operand, struct Operand);
int32_t emitStoreAbs(int, struct Operand, struct Operand);
int32_t emitStoreInd(struct Operand, struct Operand);
int32_t emitStoreBase(int, struct Operand, struct Operand, struct Operand);
int32_t emitHalt();
*/

int32_t emitLoadImm(int, struct Operand, struct Operand);
int32_t emitLoadAbs(int, struct Operand, struct Operand);
int32_t emitLoadInd(struct Operand, struct Operand);
int32_t emitLoadBase(int, struct Operand, struct Operand, struct Operand);
int32_t emitStoreAbs(int, struct Operand, struct Operand);
int32_t emitStoreInd(struct Operand, struct Operand);
int32_t emitStoreBase(int, struct Operand, struct Operand, struct Operand);

int32_t emitBinary(int32_t, int, struct Operand, struct Operand);
int32_t emitCondJump(int32_t, int, struct Operand, struct Operand);
int32_t emitUnitary(int32_t, int, struct Operand);
int32_t emitLoad(int, struct Operand, struct Operand, struct Operand);
int32_t emitStore(int, struct Operand, struct Operand, struct Operand);

void resolveLables(struct Instruction**, int32_t*);
void updateTable(char*, int);

void cleanup();

extern const int32_t addcode;
extern const int32_t subcode;
extern const int32_t multcode;
extern const int32_t divcode;
extern const int32_t modcode;
extern const int32_t andcode;
extern const int32_t orcode;
extern const int32_t xorcode;
extern const int32_t rotatecode;

extern const int32_t negcode;
extern const int32_t notcode;
extern const int32_t movecode;

extern const int32_t jumpzcode;
extern const int32_t jumpncode;
extern const int32_t jumpnzcode;
extern const int32_t jumpcode;

extern const int32_t callcode;
extern const int32_t pushcode;
extern const int32_t popcode;
extern const int32_t returncode;
extern const int32_t trapcode;
extern const int32_t resetcode;
extern const int32_t setcode;
extern const int32_t haltcode;

extern const int32_t loadImmcode;
extern const int32_t loadAbscode;
extern const int32_t loadIndcode;
extern const int32_t loadBasDispcode;
extern const int32_t storeAbscode;
extern const int32_t storeIndcode;
extern const int32_t storeBasDispcode;

#endif //ASSEMBLE_H
