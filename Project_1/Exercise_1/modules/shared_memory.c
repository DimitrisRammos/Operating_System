//////////////////////////////////////////////
//                                          //
//              SHARED_MEMORY               //  
//                                          //
//////////////////////////////////////////////


#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/types.h>
#include <sys/ipc.h>
#include <sys/shm.h>
#include <stdbool.h>

#include "shared_memory.h"

#define IPC_RESULT_ERROR (-1)

//get shared block
static int get_shared_block(char *filename, int size)
{
    key_t key;

    //take one key for thus filname
    key = ftok(filename,0);
    if( key == IPC_RESULT_ERROR)
    {
        return IPC_RESULT_ERROR;
    }
    return shmget(key,size, 0644 | IPC_CREAT);
}

char* attach_memory_block(char *filename, int size)
{   
    //tale the shared_block_id
    int shared_block_id = get_shared_block(filename, size);
    char* result;
    if( shared_block_id == IPC_RESULT_ERROR)
    {
        return NULL;
    }


    result = shmat( shared_block_id, NULL, 0);
    if( result == (char*)IPC_RESULT_ERROR)
    {
        return NULL;
    }

    return result;
}

//i do detach memory
bool detach_memory_block(char *block)
{
    return(shmdt(block) != IPC_RESULT_ERROR);
}

//////////////////////////////////////////////
//                                          //
//                  END                     //  
//                                          //
//////////////////////////////////////////////