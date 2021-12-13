//////////////////////////////////////////////
//                                          //
//              CHILD_PROCESS               //  
//                                          //
//////////////////////////////////////////////

#include "inclu.h"
#include "shared_memory.h"


int main(int argc, char* argv[])
{   
    
    srand(time(NULL));
    if( argc != 3)
    {
        printf("WRONG INPUT FROM ARGS!!!\n");
        exit(EXIT_FAILURE);    
    }



    //i will take 3 semaphores
    sem_t *sem_parent = sem_open( SEM_PARENT_PROCESS, 0);
    if(sem_parent == SEM_FAILED)
    {
        perror("sem_open/parent");
        exit(EXIT_FAILURE);
    }

    sem_t *sem_child = sem_open( SEM_CHILD_PROCESS, 0);
    if(sem_child == SEM_FAILED)
    {
        perror("sem_open/child");
        exit(EXIT_FAILURE);
    }

    sem_t *sem_child_2 = sem_open( SEM_CHILD2_PROCESS,0);
    if( sem_child_2 == SEM_FAILED)
    {
        perror("sem_open/child2");
        exit(EXIT_FAILURE);
    }

    //παιρνω την κοινοχρηστη μνημη που χει δημιουργηθει
    char* block = attach_memory_block( FILENAME, BLOCK_SIZE);
    if(block == NULL)
    {
        printf("ERRORRR \n");
        return -1;
    }


    int N = atoi(argv[1]);      //Ν ποσες δοσοληψιες θα γινουν
    int Lines = atoi(argv[2]);  //Lines ποσες γραμμες υπαρχουν
    
    int t1,t2;
    for( int i = 0; i < N; i++)
    {   
        // t1 = time(NULL);

        //ριχνω τον σημαφορο 
        sem_wait(sem_child);
        int random = rand()%Lines + 1;  //διαλεγω τυχαια γραμμη
        
        //γραφω στην κοινοχρηστη μνημη την γραμμη ωστε να γνωριζει
        //o parent
        char* line = malloc(sizeof(char));
        sprintf(line,"%d",random);
        strncpy(block,line,BLOCK_SIZE);
        printf("Child process - with pid = %d  I want the line with number - %d\n", getpid(),random);
        
        free(line);
    
        
        sem_post(sem_parent);
        sem_wait(sem_child_2);
        
        printf("Child process: My line is -  %s\n\n\n\n",block);
        sem_post( sem_child);
    }

    //close semaphores
    sem_close(sem_child);
    sem_close(sem_child_2);
    sem_close(sem_parent);
    detach_memory_block(block);


    return 0;
}

//////////////////////////////////////////////
//                                          //
//                  END                     //  
//                                          //
//////////////////////////////////////////////