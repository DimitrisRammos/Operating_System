#include <stdlib.h>
#include <string.h>
#include <sys/sem.h>
#include <sys/shm.h>
#include <sys/wait.h>


#include <sys/types.h>
#include <sys/ipc.h>

#include <semaphore.h>
#include <stdbool.h>
#include <stdio.h>
#include "s_memory.h"

#define NUM_ITERATIONS 10


int main( int argc, char* argv[])
{
    if(argc != 2)
    {
        printf("usage -%s [stuff to write]",argv[0]);
    }
    
    sem_t *sem_prod = sem_open( SEM_PRODUCER_FNAME,0);
    if(sem_prod == SEM_FAILED)
    {
        perror("sem_open/producer");
        exit(EXIT_FAILURE);
    }

    sem_t *sem_cons = sem_open( SEM_CONSUMER_FNAME,0);
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

    for( int i = 0; i <NUM_ITERATIONS; i++)
    {   
        sem_wait(sem_cons);
        printf("Writing \"%s\"\n",argv[1]);
        sleep(3);
        strncpy(block,argv[1],BLOCK_SIZE);
        sem_post(sem_prod);
    }

    sem_close(sem_prod);
    sem_close(sem_cons);
    detach_memory_block(block);
    return 0;

}