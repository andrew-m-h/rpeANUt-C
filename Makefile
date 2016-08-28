all: rpeanutc ras rpp

rpeanutc: src/rpeanutc/memory.c include/rpeanutc/memory.h src/rpeanutc/emulate.c include/rpeanutc/emulate.h include/rpeanutc/interrupt.h src/rpeanutc/rpeanutc.c
	cc -o rpeanutc -std=gnu11 -Wall -O2 -I include/rpeanutc src/rpeanutc/*.c


ras: src/ras/parser.tab.c include/ras/parser.tab.h src/ras/tokenizer.yy.c src/ras/ras.c include/ras/parser.h include/ras/assemble.h src/ras/assemble.c
	cc -o ras -std=c11 -Wall -I include/ras src/ras/*.c -Wno-pointer-to-int-cast -Wno-int-to-pointer-cast -Wno-unused-function

rpp: src/rpp/parser.tab.c include/rpp/parser.tab.h src/rpp/tokenizer.yy.c src/rpp/rpp.c
	cc -o rpp -std=c11 -Wall -I include/rpp src/rpp/*.c -Wno-unused-function

src/ras/parser.tab.c include/ras/parser.tab.h: src/ras/parser.y
	bison -d src/ras/parser.y
	mv -f parser.tab.h include/ras/
	mv -f parser.tab.c src/ras/

src/ras/tokenizer.yy.c: src/ras/tokenizer.l include/ras/parser.h include/ras/parser.tab.h
	flex -o src/ras/tokenizer.yy.c src/ras/tokenizer.l

src/rpp/parser.tab.c include/rpp/parser.tab.h: src/rpp/parser.y
	bison -d src/rpp/parser.y
	mv -f parser.tab.h include/rpp/
	mv -f parser.tab.c src/rpp/

src/rpp/tokenizer.yy.c: src/rpp/tokenizer.l include/rpp/parser.h include/rpp/parser.tab.h
	flex -o src/rpp/tokenizer.yy.c src/rpp/tokenizer.l

clean:
	rm -f src/ras/tokenizer.yy.c
	rm -f src/ras/parser.tab.c
	rm -f include/ras/parser.tab.h
	rm -f src/rpp/tokenizer.yy.c
	rm -f src/rpp/parser.tab.c
	rm -f include/rpp/parser.tab.h
	rm -f rpp
	rm -f ras
	rm -f rpeanutc
