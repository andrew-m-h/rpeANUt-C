#include <stdio.h>
#include <stdlib.h>

#include "parser.h"
#include "parser.tab.h"
#include "assemble.h"

//#define DEBUG

int main( int argc, char **argv )
{
    ++argv, --argc;  /* skip over program name */

    if ( argc > 0 )
        yyin = fopen( argv[0], "r" );
    else
        yyin = stdin;

    do {
        yyparse();
    } while (!feof(yyin));

    int32_t program[ADDRESSABLE_MEMORY] = {0};
#ifdef DEBUG
    int len = assemble(Instructions, InstrCount, program);
    for (int i = 0; i < len; i++){
        fprintf(stderr, "%08x\n", program[i]);
    }



#else
    assemble(Instructions, InstrCount, program);
#endif
    fwrite(program, sizeof(int32_t), ADDRESSABLE_MEMORY, stdout);

    cleanup();
    return EXIT_SUCCESS;
}
