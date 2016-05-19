#!/bin/bash
DIFF="diff -s -"

for i in `seq 0 11`;
do
    cat tests/test$i.png.B | ./rpeanutc prog.asm | $DIFF tests/test$i.png.dmp;
    cat tests/test$i.png.H | ./rpeanutc prog.asm | $DIFF tests/test$i.png.dmp;
    cat tests/test$i.png.X | ./rpeanutc prog.asm | $DIFF tests/test$i.png.dmp;
done
