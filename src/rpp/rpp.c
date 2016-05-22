#include <stdlib.h>
#include <stdio.h>
#include <search.h>
#include "parser.h"
#include "parser.tab.h"

int main(int argc, char* argv[]){
    hcreate(100);
    ++argv, --argc;  /* skip over program name */

    if ( argc > 0 )
        yyin = fopen( argv[0], "r" );
    else
        yyin = stdin;
    do {
        yyparse();
    } while (!feof(yyin));

    printf("%s", outputFile);

    hdestroy();

    return EXIT_SUCCESS;
}
