%{
    #include <stdio.h>
    #include <stdlib.h>
    #include <string.h>
    #include <search.h>
    #include <unistd.h>
    #include <sys/wait.h>
    #include "parser.h"

    char outputFile[FILE_LENGTH] = {0};
    int fileLen = 0;

    void insertDefinition(char * lable, char * expansion){
        ENTRY e;
        e.key = lable;
        e.data = (void*)expansion;
        hsearch(e, ENTER);
    }

    char* lookupLable(char * lable){
        ENTRY e, *ep;
        e.key = (void*) lable;
        ep = hsearch(e, FIND);
        if (ep == NULL){
            return lable;
        } else {
            return (char*)ep->data;
        }
    }

    void includeFile(char * filename){
        int fd[2];
        int pid;
        int len;
        int status;
        char * args[3];
        pipe(fd);
        switch (pid = fork()){
        case 0: //child
            args[0] = "./rpp";
            args[1] = filename;
            args[2] = NULL;

            close(fd[0]);
            dup2(fd[1], 1);
            close(fd[1]);

            execvp(args[0], args);

            return;
        case -1: //error
            perror("fork");
            exit(1);

        default: //parent
            close(fd[1]);
            len = read(fd[0], outputFile + fileLen, FILE_LENGTH - fileLen);
            waitpid(pid, &status, 0);
            close(fd[0]);
        }
        fileLen += len;
    }
%}

%union {
    char cval;
    char* sval;
}

%token <sval> MACRO_ARG
%token <sval> LABLE
%token <sval> FILENAME
%token <sval> EXPANSION
%token <cval> CHAR

%token LINE_MACRO
%token INCLUDE_MACRO
%token ENDL

%%

file:
    expression
    | file expression
    ;

expression:
    lineMacro
    | includeMacro
    | LABLE      {char * str = lookupLable($1); strcpy(outputFile + fileLen, str); fileLen += strlen(str);}
    | CHAR       {outputFile[fileLen++] = $1;}
    ;

includeMacro:
    INCLUDE_MACRO FILENAME ENDL            {includeFile($2);}
    ;

lineMacro:
    LINE_MACRO LABLE EXPANSION ENDL    {insertDefinition($2, $3); strcpy(outputFile + fileLen, ";; macro defined\n"); fileLen+=17;}
    ;

%%

void yyerror(const char *s) {
    printf ("Parse Error! Message: %s\n", s);
    exit(-1);
}
