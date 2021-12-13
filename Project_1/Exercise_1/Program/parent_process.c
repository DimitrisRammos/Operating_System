//////////////////////////////////////////////
//                                          //
//             PARENT_PROCESS               //  
//                                          //
//////////////////////////////////////////////


#include "inclu.h"
#include "shared_memory.h"

int main(int argc, char* argv[])
{   
    if( argc != 4)
    {
        printf("WRONG INPUT FROM ARGS!!!\n");
        exit(EXIT_FAILURE);
    }


    //διαγραφω τυχον σημαφορους με το ιδιο ονομα
    sem_unlink(SEM_CHILD_PROCESS);
    sem_unlink(SEM_PARENT_PROCESS);
    sem_unlink(SEM_CHILD2_PROCESS);



    //i will create 3 semaphores
    sem_t *sem_parent = sem_open( SEM_PARENT_PROCESS,O_CREAT,0660,0);
    if(sem_parent == SEM_FAILED)
    {
        perror("sem_open/parent");
        exit(EXIT_FAILURE);
    }

    sem_t *sem_child = sem_open( SEM_CHILD_PROCESS,O_CREAT,0660,1);
    if(sem_child == SEM_FAILED)
    {
        perror("sem_open/child");
        exit(EXIT_FAILURE);
    }

    sem_t *sem_child_2 = sem_open( SEM_CHILD2_PROCESS ,O_CREAT,0660,0);
    if(sem_child_2 == SEM_FAILED)
    {
        perror("sem_open/child2");
        exit(EXIT_FAILURE);
    }



    //open file
    //and i will find how much is the line in the file
    char* filename = argv[1];

    FILE *in_file ;
    in_file = fopen(filename,"r");
    
    if( in_file == NULL)
    {
        perror("file FAILED");
        exit(EXIT_FAILURE);
    }

    //μετραω ποσες γραμμες εχεο τπ αρχειο που μου δινετε
    char ch[101];
    int lines = 0;
    while(fgets(ch, 100, in_file))
    {
        lines++;
        
    }
    if( lines == 0)
    {
        perror("Wrong lines in file");
        exit( EXIT_FAILURE);
    }
    //convert the Lines from int to string for input in the next prorgram(child_process)
    char* Lines = malloc(sizeof(char));
    sprintf(Lines,"%d",lines);
    fclose(in_file);
    
    //K is the number for the process
    int K = atoi(argv[2]);
    if( K <= 0)
    {
        perror("Wrong input for process");
        exit( EXIT_FAILURE);
    }
    pid_t pid[K];

    int N = atoi(argv[3]);
    if( N <= 0)
    {
        perror("Wrong input for requests");
        exit( EXIT_FAILURE);
    }

    //process
    for( int i = 0; i < K; i++)
    {   
        //αποθηκευω το pid σε πινακα
        if((pid[i] = fork()) < 0)
        {   
            perror("Failed fork");
            exit(EXIT_FAILURE);
        }

        if( pid[i] == 0)
        {   
            //αντικαθιστω το μερος της διεργασιας με ενα αλλο προγραμμα
            if(execl(CHILD_PROGRAM,CHILD_PROGRAM,argv[3], Lines,NULL) < 0)
            {
                perror("Failed EXECL");
                exit(EXIT_FAILURE);
            }
            exit(1);
        }
    }

    //δημιουργω με κοινοχρηστη μνημη
    char* block = attach_memory_block( FILENAME, BLOCK_SIZE);
    if(block == NULL)
    {
        printf("ERRORRR \n");
        return -1;
    }

    int P = K*N; //το P ειναι ποσα request θα γινουν συνολικα προς το πατερα
    while(P>0)
    {   

        
        sem_wait( sem_parent);

        //διαβαζω την κοινοχρηστη μνημη
        if(strlen(block) > 0)
        {   
            int input = atoi(block);
            block[0] = 0;
            printf("Parent process- My child want the line with number = %d\n",input);
            
            //ανοιγω το αρχειο
            in_file = fopen(filename,"r");

            if( in_file == NULL)
            {
                perror("file FAILED");
                exit(EXIT_FAILURE);
            }

            char ch[101];
            int l = 0;
            //βρισκω την γραμμη και τη γραφω στη μνημη
            while(fgets(ch, 100, in_file))
            {
                l++;
                if(l == input)
                {   
                    
                    int size = strlen(ch) - 1;
                    if(ch[size] == '\n' && l != lines)
                    {
                        ch[size] = '\0';
                    }
                    strncpy(block,ch,BLOCK_SIZE);

                    printf("Parent process: Your line is: %s\n",ch);
                    break;
                }
            }

            fclose(in_file);


        }

        P--;
        
        // sem_post( sem_child);
        sem_post(sem_child_2);
    }
    
    //μαζευω ολα τα pid
    for(int i = 0; i < K; i++)
    {
        if(waitpid(pid[i],NULL,0) < 0)
        {
            perror("Waitpid failed");
        }
    }
    

    //close semaphores
    sem_close(sem_child);
    sem_close(sem_child_2);
    sem_close(sem_parent);


    detach_memory_block(block);
    free(Lines);
}

//////////////////////////////////////////////
//                                          //
//                  END                     //  
//                                          //
//////////////////////////////////////////////