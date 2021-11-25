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
#include <assert.h>
#include <fcntl.h>
#include <errno.h>
#include <unistd.h>
#include <sys/file.h>
#include <sys/stat.h>
#include <sys/types.h>

#define CHILD_PROGRAM "./child_process"

int main(int argc, char* argv[])
{   
    if( argc != 4)
    {
        printf("WRONG INPUT FROM ARGS!!!\n");
        exit(EXIT_FAILURE);
    }

    int X = atoi(argv[1]);
    int K = atoi(argv[2]);
    int N = atoi(argv[3]); 

    pid_t pid[10];

    for( int i = 0; i < K; i++)
    {   
        if((pid[i] = fork()) < 0)
        {   
            perror("Failed fork");
            exit(EXIT_FAILURE);
        }

        if( pid[i] == 0)
        {
            if(execl(CHILD_PROGRAM,CHILD_PROGRAM,NULL) < 0)
            {
                perror("Failed EXECL");
                exit(EXIT_FAILURE);
            }
            exit(1);
        }
    }

    for(int i = 0; i < K; i++)
    {
        if(waitpid(pid[i],NULL,0) < 0)
        {
            perror("Waitpid failed");
        }
    }


}