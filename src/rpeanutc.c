#include <stdio.h>
#include <stdlib.h>

#include "emulate.h"
#include "memory.h"

void dump(int32_t*);

int main( int argc, char **argv )
{
    ++argv, --argc;  /* skip over program name */
    FILE * input;
    if (argc > 0)
        input = fopen( argv[0], "r" );
    else
        input = stdin;

    fread(Memory, sizeof(int32_t), ADDRESSABLE_MEMORY, input);

    emulate();

    dump(Memory+0x7C40);

    return EXIT_SUCCESS;
}

void dump(int32_t output[]){
    for (int y = 0; y < 160; y++){
        printf("%d", y);
        for (int x = 0; x < 6; x++){
            printf(":%08x", output[x + y * 6]);
        }
        printf("\n");
    }
}
