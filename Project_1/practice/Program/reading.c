#include <stdlib.h>
#include <string.h>
#include <sys/types.h>
#include <sys/ipc.h>
#include <sys/sem.h>

#include <sys/shm.h>
#include <sys/wait.h>

#include <semaphore.h>
#include <stdbool.h>
#include <stdio.h>
#include "s_memory.h"


#include <assert.h>
#include <fcntl.h>
#include <errno.h>
#include <unistd.h>
#include <sys/file.h>
#include <sys/stat.h>
#include <sys/types.h>

#define NUM_ITERATIONS 10


int main( int argc, char *argv[])
{
    if(argc != 1)
    {
        printf("usage -%s //no args",argv[0]);
    }

    sem_unlink(SEM_CONSUMER_FNAME);
    sem_unlink(SEM_PRODUCER_FNAME);
    
    sem_t *sem_prod = sem_open( SEM_PRODUCER_FNAME,O_CREAT,0660,0);
    if(sem_prod == SEM_FAILED)
    {
        perror("sem_open/producer");
        exit(EXIT_FAILURE);
    }

    sem_t *sem_cons = sem_open( SEM_CONSUMER_FNAME,O_CREAT,0660,1);
    if(sem_cons == SEM_FAILED)
    {
        perror("sem_open/consumer");
        exit(EXIT_FAILURE);
    }

    char *block = attach_memory_block( FILENAME, BLOCK_SIZE);
    if(block == NULL)
    {
        printf("ERRORRR \n");
        return -1;
    }

    printf("prod: %d - cons: %d\n",*sem_prod,*sem_cons);


    while(true)
    {     
        sem_wait(sem_prod);
        if (strlen(block) > 0)
        {
            printf("REAFING: \"%s\"\n",block);
            bool done = (strcmp(block,"quit") == 0);
            block[0] = 0;
            if(done){break;} 
        }
        sem_post(sem_cons);
    }

    sem_close(sem_cons);
    sem_close(sem_prod);
    detach_memory_block(block);
    return 0;

}