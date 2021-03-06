#include <stdio.h>
#include <stdlib.h>
#include <signal.h>

#include "emulate.h"
#include "memory.h"
#include "interrupt.h"

void dump(int32_t[]);

void sigintHandler(int);

int main( int argc, char **argv )
{
    if (signal(SIGINT, sigintHandler) == SIG_ERR){
        perror("Signal error");
        exit(1);
    }
    //disable buffering for stdout (its not needed)
    setvbuf(stdout, NULL, _IONBF, 0);

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

void sigintHandler(int signo){
    switch (signo){
    case SIGINT:
        dump(Memory+0x7C40);
        exit(EXIT_SUCCESS);
        break;
    default: break;
    }
}
