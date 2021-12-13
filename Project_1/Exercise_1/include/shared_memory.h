#ifndef S_MEMORY_H
#define S_MEMORY_H

#include <stdbool.h>

char * attach_memory_block(char *filename,int size);
bool detach_memory_block( char *block);

#define BLOCK_SIZE 4096
#define FILENAME "child_process.c"
#define IPC_RESULT_ERROR (-1)


#endif