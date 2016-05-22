#!/bin/bash
DIFF="diff -s -"

./rpp loadimage.s | ./ras > loadimage.asm
for i in `seq 0 11`;
do
    cat tests/test$i.png.B | ./rpeanutc loadimage.asm | $DIFF tests/test$i.png.dmp;
    cat tests/test$i.png.H | ./rpeanutc loadimage.asm | $DIFF tests/test$i.png.dmp;
    cat tests/test$i.png.X | ./rpeanutc loadimage.asm | $DIFF tests/test$i.png.dmp;
done
