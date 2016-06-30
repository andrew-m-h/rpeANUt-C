#include <stdio.h>
#include <stdlib.h>

#include "parser.h"
#include "parser.tab.h"

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

    jit(Instructions, InstrCount)


    return EXIT_SUCCESS;
}
