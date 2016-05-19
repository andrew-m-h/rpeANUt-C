all: rpeanutc ras

rpeanutc: src/memory.c include/memory.h src/emulate.c include/emulate.h include/interrupt.h src/rpeanutc.c
	gcc -o rpeanutc -std=gnu11 -Wall -I include src/rpeanutc.c src/memory.c src/emulate.c

ras: src/parser.tab.c include/parser.tab.h src/tokenizer.yy.c src/ras.c include/parser.h include/assemble.h src/assemble.c
	gcc -g -o ras -std=c11 -Wall -I include src/parser.tab.c src/ras.c src/tokenizer.yy.c src/assemble.c -Wno-pointer-to-int-cast -Wno-int-to-pointer-cast -Wno-unused-function

src/parser.tab.c include/parser.tab.h: src/parser.y
	bison -d src/parser.y
	mv -f parser.tab.h include/
	mv -f parser.tab.c src/

src/tokenizer.yy.c: src/tokenizer.l include/parser.h include/parser.tab.h
	flex -o src/tokenizer.yy.c src/tokenizer.l

clean:
	rm -f src/tokenizer.yy.c
	rm -f src/parser.tab.c
	rm -f include/parser.tab.h
	rm -f ras
	rm -f rpeanutc
