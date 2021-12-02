#include <stdlib.h>
#include <time.h>
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
#define SEM_PARENT_PROCESS "/parent"
#define SEM_CHILD_PROCESS "/child"
#define SEM_CHILD2_PROCESS "/child2"